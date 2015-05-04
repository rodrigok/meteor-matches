Meteor.publish 'scoreRequests', ->
	return ScoreRequests.find()

Meteor.publish 'matches', ->
	return Matches.find()

Meteor.publish 'users', ->
	return Meteor.users.find()


Meteor.methods
	approve: (matchId) ->
		ScoreRequests.update {match: matchId, needsApprovalFrom: this.userId}, {$pull: {needsApprovalFrom: this.userId}}
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
		ScoreRequests.remove {match: matchId, needsApprovalFrom: this.userId}

	updateUserName: (userName) ->
		Meteor.users.update this.userId, {$set: {'profile.name': userName}}