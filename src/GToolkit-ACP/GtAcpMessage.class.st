Class {
	#name : 'GtAcpMessage',
	#superclass : 'Object',
	#instVars : [
		'role',
		'contentBlocks',
		'toolCalls',
		'isComplete',
		'announcer'
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

{ #category : 'building' }
GtAcpMessage >> addContentBlock: aBlock [
	contentBlocks add: aBlock.
	announcer announce: GtAcpMessageUpdated new
]

{ #category : 'building' }
GtAcpMessage >> addToolCall: aToolCall [
	toolCalls add: aToolCall.
	announcer announce: GtAcpMessageUpdated new
]

{ #category : 'accessing' }
GtAcpMessage >> announcer [
	^ announcer
]

{ #category : 'building' }
GtAcpMessage >> appendText: aString [
	| lastBlock |
	lastBlock := contentBlocks ifNotEmpty: [ contentBlocks last ] ifEmpty: [ nil ].
	(lastBlock notNil and: [ lastBlock isKindOf: GtAcpTextBlock ])
		ifTrue: [ lastBlock appendText: aString ]
		ifFalse: [ contentBlocks add: (GtAcpTextBlock new text: aString; yourself) ].
	announcer announce: GtAcpMessageUpdated new
]

{ #category : 'accessing' }
GtAcpMessage >> contentBlocks [
	^ contentBlocks
]

{ #category : 'printing' }
GtAcpMessage >> fullText [
	^ String streamContents: [ :stream |
		contentBlocks
			select: [ :block | block isKindOf: GtAcpTextBlock ]
			thenDo: [ :block | stream nextPutAll: block text; cr ] ]
]

{ #category : 'gt views' }
GtAcpMessage >> gtContentFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Content';
		priority: 10;
		items: [ contentBlocks, toolCalls ];
		column: 'Type' text: [ :item |
			(item isKindOf: GtAcpTextBlock)
				ifTrue: [ 'Text' ]
				ifFalse: [ (item isKindOf: GtAcpToolCall)
					ifTrue: [ 'Tool Call' ]
					ifFalse: [ item class name ] ] ] width: 100;
		column: 'Preview' text: [ :item |
			(item isKindOf: GtAcpTextBlock)
				ifTrue: [ (item text size > 100)
					ifTrue: [ (item text first: 100), '...' ]
					ifFalse: [ item text ] ]
				ifFalse: [ (item isKindOf: GtAcpToolCall)
					ifTrue: [ item toolName, ' (', item toolCallId, ')' ]
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

{ #category : 'testing' }
GtAcpMessage >> hasToolCalls [
	^ toolCalls notEmpty
]

{ #category : 'initialization' }
GtAcpMessage >> initialize [
	super initialize.
	role := 'user'.
	contentBlocks := OrderedCollection new.
	toolCalls := OrderedCollection new.
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

{ #category : 'building' }
GtAcpMessage >> toolCallById: anId [
	^ toolCalls detect: [ :tc | tc toolCallId = anId ] ifNone: [ nil ]
]

{ #category : 'accessing' }
GtAcpMessage >> toolCalls [
	^ toolCalls
]
