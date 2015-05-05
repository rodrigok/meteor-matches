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
		Meteor.call 'createMatch', teams
