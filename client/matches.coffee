Meteor.subscribe 'users'
Meteor.subscribe 'matches'
Meteor.subscribe 'scoreRequests'

Avatar.options =
	fallbackType: 'initials'

Blaze.registerHelper 'arrayify', (obj) ->
	arr = []
	for k, v of obj
		arr.push
			key: k
			value: v
	return arr

Blaze.registerHelper 'getAt', (arr, index) ->
	return arr[index]

Session.setDefault('teams', {})

Template.login.events
	'keydown input.username': (e) ->
		if e.keyCode is 13
			Meteor.call 'updateUserName', e.currentTarget.value

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
		data =
			match: this.match._id
			team: this.team.key
			score: 1
			needsApprovalFrom: _.without(this.match.users, Meteor.userId())
			createdAt: new Date
			createdBy: Meteor.userId()

		ScoreRequests.insert data

	'click a.approve': (e) ->
		Meteor.call 'approve', this._id

	'click a.reject': (e) ->
		Meteor.call 'reject', this._id


Template.newMatch.helpers
	users: ->
		return Meteor.users.find()
	getUserTeam: (userId) ->
		teams = Session.get 'teams'
		return teams[userId]
	userInTeamClass: (team) ->
		teams = Session.get 'teams'
		if not teams[this._id]?
			return 'asd'
		if teams[this._id] is team
			return 'in-team'
		return 'not-in-team'
	validTeam: ->
		teams = Session.get 'teams'
		if Object.keys(teams).length < 2
			return false

		t = {}
		for k, v of teams
			t[v] ?= 0
			t[v]++

		return t[1]? and t[2]?


Template.newMatch.events
	'click .team-1 .avatar': ->
		teams = Session.get 'teams'
		if teams[this.user._id] is 1
			delete teams[this.user._id]
		else
			teams[this.user._id] = 1
		Session.set 'teams', teams

	'click .team-2 .avatar': ->
		teams = Session.get 'teams'
		if teams[this.user._id] is 2
			delete teams[this.user._id]
		else
			teams[this.user._id] = 2
		Session.set 'teams', teams

	'click a': ->
		teams = Session.get 'teams'
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
