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
		request = ScoreRequests.findOne({match: m._id, team: teamId, 'needsApprovalFrom.0': {$exists: true}})
		if request?
			result.pending = request.score
		return result
	approvalPending: (m, userId) ->
		return if ScoreRequests.findOne({match: m._id, 'needsApprovalFrom': userId})? then 'pending' else ' '
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