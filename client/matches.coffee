Template.matches.helpers
	Matches: ->
		query = {}
		teams = Session.get('teams')
		if Object.keys(teams).length > 0
			query =
				users: $all: Object.keys(teams)

		return Matches.find(query, {sort: {count: 1}})
	placeHoldersForTeam: (m, users) ->
		length = m.biggestTeam - users.length
		return [0...length]
	getScore: (m, teamId) ->
		result =
			score: m.score[teamId]

		pending = 0
		ScoreRequests.find({match: m._id, team: teamId, 'needsApprovalFrom.0': {$exists: true}}).fetch().forEach (request) ->
			pending += request.score
		result.pending = pending if pending > 0
		return result
	approvalPending: (m, userId) ->
		return if ScoreRequests.findOne({match: m._id, 'needsApprovalFrom': userId})? then 'pending' else ' '
	needsApproval: (m) ->
		return ScoreRequests.findOne({match: m._id, 'needsApprovalFrom': Meteor.userId()})?
	canAddScore: (m) ->
		return Meteor.userId() in m.users

Template.matches.events
	'click a.add-score': (e) ->
		Meteor.call 'createScoreRequest', this.match._id, this.team.key

	'click a.approve': (e) ->
		Meteor.call 'approve', this._id

	'click a.reject': (e) ->
		Meteor.call 'reject', this._id
