Meteor.methods
	approve: (matchId) ->
		if not @userId?
			return

		ScoreRequests.update {match: matchId, needsApprovalFrom: this.userId}, {$pull: {needsApprovalFrom: this.userId}}, { multi: true }
		pipeline = []
		pipeline.push
			$match:
				match: matchId
				'needsApprovalFrom.0': {$exists: false}
		pipeline.push
			$group:
				_id: '$team'
				count: $sum: '$score'
		agg = ScoreRequests.aggregate pipeline
		for item in agg
			update = {$set: {}}
			update.$set["score.#{item._id}"] = item.count
			Matches.update {_id: matchId}, update

	reject: (matchId) ->
		if not @userId?
			return

		ScoreRequests.remove {match: matchId, needsApprovalFrom: this.userId}

	updateUserName: (userName) ->
		if not @userId?
			return

		Meteor.users.update this.userId, {$set: {'profile.name': userName}}

	createMatch: (teams) ->
		if not @userId?
			return

		teamIds = {}
		userIds = []
		for k, v of teams
			teamIds[v] ?= []
			teamIds[v].push k
			userIds.push k

		ids = []
		biggestTeam = 0
		for k, v of teamIds
			if v.length > biggestTeam
				biggestTeam = v.length
			teamIds[k] = v.sort (a, b) ->
				return a > b
			ids.push teamIds[k].join(',')

		ids = ids.sort (a, b) ->
			return a > b

		userIdsByTeam = {}
		score = {}
		for id in ids
			score[id] = 0
			userIdsByTeam[id] = id.split(',')

		ids = ids.join('|')

		data =
			_id: ids
			users: userIds
			count: userIds.length
			score: score
			usersByTeam: userIdsByTeam
			biggestTeam: biggestTeam
			createdAt: new Date
			createdBy: Meteor.userId()

		Matches.insert data

	createScoreRequest: (matchId, teamId, score=1) ->
		if not @userId?
			return

		check matchId, String
		check teamId, String

		match = Matches.findOne matchId

		if not match?
			throw new Meteor.Error 'Match not found'

		data =
			match: matchId
			team: teamId
			score: score
			needsApprovalFrom: _.without(match.users, @userId)
			createdAt: new Date
			createdBy: @userId

		ScoreRequests.insert data
