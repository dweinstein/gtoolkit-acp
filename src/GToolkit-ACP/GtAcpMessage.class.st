Class {
	#name : 'GtAcpMessage',
	#superclass : 'Object',
	#instVars : [
		'role',
		'contentItems',
		'isComplete',
		'announcer',
		'thinking'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpMessage class >> assistant [
	^ self new
		role: 'assistant';
		yourself
]

{ #category : 'instance creation' }
GtAcpMessage class >> user: aString [
	^ self new
		role: 'user';
		addContentBlock: (GtAcpTextBlock new text: aString; yourself);
		yourself
]

{ #category : 'updating' }
GtAcpMessage >> addContentBlock: aBlock [
	contentItems add: aBlock.
	announcer announce: GtAcpMessageUpdated new
]

{ #category : 'updating' }
GtAcpMessage >> addToolCall: aToolCall [
	contentItems add: aToolCall.
	announcer announce: GtAcpMessageUpdated new
]

{ #category : 'accessing' }
GtAcpMessage >> announcer [
	^ announcer
]

{ #category : 'updating' }
GtAcpMessage >> appendText: aString [
	| lastItem |
	lastItem := contentItems ifNotEmpty: [ contentItems last ] ifEmpty: [ nil ].
	(lastItem notNil and: [ lastItem isKindOf: GtAcpTextBlock ])
		ifTrue: [ lastItem appendText: aString ]
		ifFalse: [ contentItems add: (GtAcpTextBlock new text: aString; yourself) ].
	announcer announce: GtAcpMessageUpdated new
]

{ #category : 'updating' }
GtAcpMessage >> appendThinking: aString [
	| delta current |
	delta := aString ifNil: [ '' ] ifNotNil: [ aString asString ].
	delta isEmpty ifTrue: [ ^ self ].
	current := thinking ifNil: [ '' ] ifNotNil: [ thinking asString ].
	thinking := current , delta.
	announcer announce: GtAcpMessageUpdated new
]

{ #category : 'accessing' }
GtAcpMessage >> contentBlocks [
	^ contentItems reject: [ :item | item isKindOf: GtAcpToolCall ]
]

{ #category : 'accessing' }
GtAcpMessage >> contentItems [
	^ contentItems
]

{ #category : 'accessing' }
GtAcpMessage >> fullText [
	^ String streamContents: [ :stream |
		contentItems
			select: [ :item | item isKindOf: GtAcpTextBlock ]
			thenDo: [ :block | stream nextPutAll: block text; cr ] ]
]

{ #category : 'gt - views' }
GtAcpMessage >> gtContentFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Content';
		priority: 10;
		items: [ contentItems ];
		column: 'Type' text: [ :item |
			(item isKindOf: GtAcpTextBlock)
				ifTrue: [ 'Text' ]
				ifFalse: [ (item isKindOf: GtAcpToolCall)
					ifTrue: [ 'Tool Call' ]
					ifFalse: [ item class name ] ] ] width: 100;
		column: 'Status' text: [ :item |
			(item isKindOf: GtAcpToolCall)
				ifTrue: [ item status ifNil: [ '' ] ]
				ifFalse: [ '' ] ] width: 80;
		column: 'Preview' text: [ :item |
			(item isKindOf: GtAcpTextBlock)
				ifTrue: [ (item text size > 100)
					ifTrue: [ (item text first: 100), '...' ]
					ifFalse: [ item text ] ]
				ifFalse: [ (item isKindOf: GtAcpToolCall)
					ifTrue: [ 
						| preview |
						preview := item title ifNil: [ 'unknown' ].
						item inputSummary ifNotNil: [ :s | preview := preview, ' - ', s ].
						preview ]
					ifFalse: [ item asString ] ] ]
]

{ #category : 'gt views' }
GtAcpMessage >> gtTextFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Text';
		priority: 20;
		text: [ self fullText ]
]

{ #category : 'views' }
GtAcpMessage >> gtThinkingFor: aView [
	<gtView>
	self hasThinking ifFalse: [ ^ aView empty ].
	^ aView textEditor
		title: 'Thinking';
		priority: 15;
		text: [ self thinking ]
]

{ #category : 'testing' }
GtAcpMessage >> hasThinking [
	^ thinking notNil and: [ thinking size > 0 ]
]

{ #category : 'testing' }
GtAcpMessage >> hasToolCalls [
	^ toolCalls notEmpty
]

{ #category : 'initialization' }
GtAcpMessage >> initialize [
	super initialize.
	role := 'user'.
	contentItems := OrderedCollection new.
	isComplete := false.
	announcer := Announcer new
]

{ #category : 'testing' }
GtAcpMessage >> isAssistant [
	^ role = 'assistant'
]

{ #category : 'accessing' }
GtAcpMessage >> isComplete [
	^ isComplete
]

{ #category : 'testing' }
GtAcpMessage >> isUser [
	^ role = 'user'
]

{ #category : 'accessing' }
GtAcpMessage >> markComplete [
	isComplete := true.
	announcer announce: GtAcpMessageCompleted new
]

{ #category : 'accessing' }
GtAcpMessage >> preview [
	| text |
	text := self fullText trimBoth.
	^ text size > 100
		ifTrue: [ (text first: 100) , '...' ]
		ifFalse: [ text ]
]

{ #category : 'printing' }
GtAcpMessage >> printOn: aStream [
	| text preview |
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: role.
	text := self fullText.
	text ifNotEmpty: [
		preview := (text size > 50)
			ifTrue: [ (text first: 50), '...' ]
			ifFalse: [ text ].
		aStream nextPutAll: ': "'.
		aStream nextPutAll: preview.
		aStream nextPut: $" ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtAcpMessage >> role [
	^ role
]

{ #category : 'accessing' }
GtAcpMessage >> role: aString [
	role := aString
]

{ #category : 'accessing' }
GtAcpMessage >> thinking [
	^ thinking ifNil: [ '' ] ifNotNil: [ thinking asString ]
]

{ #category : 'building' }
GtAcpMessage >> toolCallById: anId [
	^ toolCalls detect: [ :tc | tc toolCallId = anId ] ifNone: [ nil ]
]

{ #category : 'accessing' }
GtAcpMessage >> toolCalls [
	^ contentItems select: [ :item | item isKindOf: GtAcpToolCall ]
]
