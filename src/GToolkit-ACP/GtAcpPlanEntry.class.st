Class {
	#name : 'GtAcpPlanEntry',
	#superclass : 'Object',
	#instVars : [
		'content',
		'priority',
		'status'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpPlanEntry class >> fromDictionary: aDictionary [
	^ self new
		content: (aDictionary at: 'content' ifAbsent: [ '' ]);
		priority: (aDictionary at: 'priority' ifAbsent: [ 'medium' ]);
		status: (aDictionary at: 'status' ifAbsent: [ 'pending' ]);
		yourself
]

{ #category : 'accessing' }
GtAcpPlanEntry >> content [
	^ content
]

{ #category : 'accessing' }
GtAcpPlanEntry >> content: aString [
	content := aString
]

{ #category : 'testing' }
GtAcpPlanEntry >> isCompleted [
	^ status = 'completed'
]

{ #category : 'testing' }
GtAcpPlanEntry >> isInProgress [
	^ status = 'in_progress'
]

{ #category : 'testing' }
GtAcpPlanEntry >> isPending [
	^ status = 'pending'
]

{ #category : 'printing' }
GtAcpPlanEntry >> printOn: aStream [
	| statusIcon |
	statusIcon := self isCompleted
		ifTrue: [ '[x]' ]
		ifFalse: [ self isInProgress
			ifTrue: [ '[~]' ]
			ifFalse: [ '[ ]' ] ].
	aStream nextPutAll: statusIcon.
	aStream nextPut: Character space.
	content ifNotNil: [ aStream nextPutAll: content ]
]

{ #category : 'accessing' }
GtAcpPlanEntry >> priority [
	^ priority
]

{ #category : 'accessing' }
GtAcpPlanEntry >> priority: aNumber [
	priority := aNumber
]

{ #category : 'accessing' }
GtAcpPlanEntry >> status [
	^ status
]

{ #category : 'accessing' }
GtAcpPlanEntry >> status: aString [
	status := aString
]
