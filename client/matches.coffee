Template.matches.helpers
	Matches: ->
		return Matches.find({}, {sort: {count: 1}})
	placeHoldersForTeam: (m, users) ->
		length = m.biggestTeam - users.length
		return [0...length]
	getScore: (m, teamId) ->
		result =
			score: m.score[teamId]
		request = ScoreRequests.findOne({match: m._id, team: teamId, 'needsApprovalFrom.0': {$exists: true}})
		if request?
			result.pending = request.score
		return result
	needsApproval: (m) ->
		return ScoreRequests.findOne({match: m._id, 'needsApprovalFrom': Meteor.userId()})?
	canAddScore: (m) ->
		if Meteor.userId() in m.users
			return not ScoreRequests.findOne({match: m._id, 'needsApprovalFrom.0': {$exists: true}})?

		return false

Template.matches.events
	'click a.add-score': (e) ->
		Meteor.call 'createScoreRequest', this.match._id, this.team.key

	'click a.approve': (e) ->
		Meteor.call 'approve', this._id

	'click a.reject': (e) ->
		Meteor.call 'reject', this._id