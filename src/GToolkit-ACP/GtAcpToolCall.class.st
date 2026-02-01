Class {
	#name : 'GtAcpToolCall',
	#superclass : 'Object',
	#instVars : [
		'toolCallId',
		'title',
		'kind',
		'status',
		'content',
		'locations',
		'rawInput',
		'rawOutput'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpToolCall class >> fromDictionary: aDictionary [
	^ self new
		toolCallId: (aDictionary at: 'tool_call_id' ifAbsent: [ nil ]);
		title: (aDictionary at: 'title' ifAbsent: [ nil ]);
		kind: (aDictionary at: 'kind' ifAbsent: [ nil ]);
		status: (aDictionary at: 'status' ifAbsent: [ 'pending' ]);
		content: (aDictionary at: 'content' ifAbsent: [ #() ]);
		locations: (aDictionary at: 'locations' ifAbsent: [ #() ]);
		rawInput: (aDictionary at: 'input' ifAbsent: [ nil ]);
		rawOutput: (aDictionary at: 'output' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'updating' }
GtAcpToolCall >> applyUpdate: aDictionary [
	(aDictionary includesKey: 'status') ifTrue: [ 
		(aDictionary at: 'status') ifNotNil: [ :value | status := value ] ].
	(aDictionary includesKey: 'title') ifTrue: [ 
		(aDictionary at: 'title') ifNotNil: [ :value | title := value ] ].
	(aDictionary includesKey: 'kind') ifTrue: [ 
		(aDictionary at: 'kind') ifNotNil: [ :value | kind := value ] ].
	(aDictionary includesKey: 'content') ifTrue: [ 
		(aDictionary at: 'content') ifNotNil: [ :value | content := value ] ].
	(aDictionary includesKey: 'locations') ifTrue: [ 
		(aDictionary at: 'locations') ifNotNil: [ :value | locations := value ] ].
	(aDictionary includesKey: 'output') ifTrue: [ 
		(aDictionary at: 'output') ifNotNil: [ :value | rawOutput := value ] ]
]

{ #category : 'accessing' }
GtAcpToolCall >> content [
	^ content
]

{ #category : 'accessing' }
GtAcpToolCall >> content: anArray [
	content := anArray
]

{ #category : 'gt views' }
GtAcpToolCall >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 10;
		items: [ {
			'toolCallId' -> toolCallId.
			'title' -> title.
			'kind' -> kind.
			'status' -> status.
			'rawInput' -> rawInput
		} ];
		column: 'Key' text: [ :assoc | assoc key ];
		column: 'Value' text: [ :assoc | assoc value asString ] width: 300
]

{ #category : 'testing' }
GtAcpToolCall >> isCompleted [
	^ status = 'completed'
]

{ #category : 'testing' }
GtAcpToolCall >> isFailed [
	^ status = 'failed'
]

{ #category : 'testing' }
GtAcpToolCall >> isInProgress [
	^ status = 'in_progress'
]

{ #category : 'testing' }
GtAcpToolCall >> isPending [
	^ status = 'pending'
]

{ #category : 'accessing' }
GtAcpToolCall >> kind [
	^ kind
]

{ #category : 'accessing' }
GtAcpToolCall >> kind: aString [
	kind := aString
]

{ #category : 'accessing' }
GtAcpToolCall >> locations [
	^ locations
]

{ #category : 'accessing' }
GtAcpToolCall >> locations: anArray [
	locations := anArray
]

{ #category : 'printing' }
GtAcpToolCall >> printOn: aStream [
	aStream nextPutAll: 'GtAcpToolCall('.
	title ifNotNil: [ aStream nextPutAll: title ] ifNil: [ aStream nextPutAll: 'untitled' ].
	aStream nextPutAll: ' - '.
	status ifNotNil: [ aStream nextPutAll: status ] ifNil: [ aStream nextPutAll: 'unknown' ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtAcpToolCall >> rawInput [
	^ rawInput
]

{ #category : 'accessing' }
GtAcpToolCall >> rawInput: anObject [
	rawInput := anObject
]

{ #category : 'accessing' }
GtAcpToolCall >> rawOutput [
	^ rawOutput
]

{ #category : 'accessing' }
GtAcpToolCall >> rawOutput: anObject [
	rawOutput := anObject
]

{ #category : 'accessing' }
GtAcpToolCall >> status [
	^ status
]

{ #category : 'accessing' }
GtAcpToolCall >> status: aString [
	status := aString
]

{ #category : 'accessing' }
GtAcpToolCall >> title [
	^ title
]

{ #category : 'accessing' }
GtAcpToolCall >> title: aString [
	title := aString
]

{ #category : 'accessing' }
GtAcpToolCall >> toolCallId [
	^ toolCallId
]

{ #category : 'accessing' }
GtAcpToolCall >> toolCallId: aString [
	toolCallId := aString
]
