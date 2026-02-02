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
	| input |
	input := aDictionary at: 'rawInput' ifAbsent: [ nil ].
	(input notNil and: [ input isEmpty ]) ifTrue: [ input := nil ].
	^ self new
		toolCallId: (aDictionary at: 'toolCallId' ifAbsent: [ nil ]);
		title: (aDictionary at: 'title' ifAbsent: [ nil ]);
		kind: (aDictionary at: 'kind' ifAbsent: [ nil ]);
		status: (aDictionary at: 'status' ifAbsent: [ 'pending' ]);
		content: (aDictionary at: 'content' ifAbsent: [ #() ]);
		locations: (aDictionary at: 'locations' ifAbsent: [ #() ]);
		rawInput: input;
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
	(aDictionary includesKey: 'rawInput') ifTrue: [
		| newInput |
		newInput := aDictionary at: 'rawInput'.
		(newInput notNil and: [ newInput notEmpty ])
			ifTrue: [ rawInput := newInput ] ].
	(aDictionary includesKey: 'rawOutput') ifTrue: [ 
		(aDictionary at: 'rawOutput') ifNotNil: [ :value | rawOutput := value ] ].
	(aDictionary includesKey: 'output') ifTrue: [ 
		(aDictionary at: 'output') ifNotNil: [ :value | rawOutput := value ] ].
	"Extract tool response from _meta if present"
	(aDictionary at: '_meta' ifAbsent: [ nil ]) ifNotNil: [ :meta |
		(meta at: 'claudeCode' ifAbsent: [ nil ]) ifNotNil: [ :cc |
			(cc at: 'toolResponse' ifAbsent: [ nil ]) ifNotNil: [ :response |
				rawOutput := response.
				status := 'completed' ] ] ]
]

{ #category : 'accessing' }
GtAcpToolCall >> content [
	^ content
]

{ #category : 'accessing' }
GtAcpToolCall >> content: anArray [
	content := anArray
]

{ #category : 'views' }
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
			'rawInput' -> rawInput.
			'rawOutput' -> rawOutput
		} ];
		column: 'Key' text: [ :assoc | assoc key ] width: 100;
		column: 'Value' text: [ :assoc | assoc value asString ] weight: 1
]

{ #category : 'accessing' }
GtAcpToolCall >> inputSummary [
	"Return a short string summarizing the key input parameter, or nil"
	(rawInput isNil or: [ rawInput isEmpty ]) ifTrue: [ ^ nil ].
	rawInput size = 1 ifTrue: [ 
		^ rawInput values first asString truncateTo: 80 ].
	"For multiple params, show first meaningful one"
	#('methodReference' 'expression' 'packageName' 'name' 'className' 'pageTitle' 'query' 'snippetUid' 'pattern') do: [ :key |
		(rawInput at: key ifAbsent: [ nil ]) ifNotNil: [ :val |
			^ val asString truncateTo: 80 ] ].
	^ rawInput keys first, ': ', (rawInput values first asString truncateTo: 60)
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
	self inputSummary ifNotNil: [ :summary |
		aStream nextPutAll: ' - '; nextPutAll: summary ].
	aStream nextPutAll: ' ['.
	status ifNotNil: [ aStream nextPutAll: status ] ifNil: [ aStream nextPutAll: 'unknown' ].
	aStream nextPutAll: ']'.
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
