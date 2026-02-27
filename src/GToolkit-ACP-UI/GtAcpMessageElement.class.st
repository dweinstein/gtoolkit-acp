Class {
	#name : 'GtAcpMessageElement',
	#superclass : 'BlElement',
	#instVars : [
		'message',
		'contentContainer',
		'roleElement',
		'thinkingElement',
		'subscriber'
	],
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'initialization' }
GtAcpMessageElement >> initialize [
	super initialize.
	subscriber := Object new.
	self layout: BlLinearLayout vertical.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical fitContent ].
	self padding: (BlInsets all: 8).
	self margin: (BlInsets top: 2 bottom: 2).
	self initializeRoleElement.
	self initializeThinkingElement.
	self initializeContentContainer.
	self addChild: roleElement as: #role.
	self addChild: thinkingElement as: #thinking.
	self addChild: contentContainer as: #content
]

{ #category : 'initialization' }
GtAcpMessageElement >> initializeContentContainer [
	contentContainer := BlElement new
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself
]

{ #category : 'initialization' }
GtAcpMessageElement >> initializeRoleElement [
	roleElement := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new bold; fontSize: 12);
		text: '';
		hMatchParent;
		vFitContent;
		margin: (BlInsets bottom: 4)
]

{ #category : 'initialization' }
GtAcpMessageElement >> initializeThinkingElement [
	thinkingElement := GtAcpThinkingElement new
		visibility: BlVisibility gone
]

{ #category : 'accessing' }
GtAcpMessageElement >> message [
	^ message
]

{ #category : 'accessing' }
GtAcpMessageElement >> message: aGtAcpMessage [
	message ifNotNil: [
		message announcer unsubscribe: self ].
	message := aGtAcpMessage.
	self updateRole.
	self updateContent.
	self updateThinking.
	message announcer
		when: GtAcpMessageUpdated
		send: #onMessageUpdated:
		to: self
]

{ #category : 'private' }
GtAcpMessageElement >> newEditorFor: aTextBlock [
	^ BrEditor new
		hMatchParent;
		vFitContentLimited;
		aptitude: BrGlamorousRegularEditorAptitude;
		beReadOnlyWithSelection;
		text: aTextBlock text asRopedText
]

{ #category : 'events' }
GtAcpMessageElement >> onMessageUpdated: anAnnouncement [
	self enqueueTask: (BlTaskAction new action: [ 
		self updateContent.
		self updateThinking ])
]

{ #category : 'updating' }
GtAcpMessageElement >> updateContent [
	| items existingChildren |
	items := message contentItems.
	existingChildren := contentContainer children asOrderedCollection.

	items withIndexDo: [ :item :index |
		index <= existingChildren size
			ifTrue: [
				| existing |
				existing := existingChildren at: index.
				(item isKindOf: GtAcpTextBlock)
					ifTrue: [
						(existing isKindOf: BrEditor)
							ifTrue: [ existing text: item text asRopedText ]
							ifFalse: [ contentContainer replaceChild: existing with: (self newEditorFor: item) ] ]
					ifFalse: [
						(item isKindOf: GtAcpToolCall)
							ifTrue: [
								((existing isKindOf: GtAcpToolCallElement)
									and: [ existing toolCall toolCallId = item toolCallId ])
									ifTrue: [ existing update ]
									ifFalse: [
										contentContainer replaceChild: existing with: (GtAcpToolCallElement new toolCall: item) ] ]
							ifFalse: [  ] ] ]
			ifFalse: [
				(item isKindOf: GtAcpTextBlock)
					ifTrue: [ contentContainer addChild: (self newEditorFor: item) ]
					ifFalse: [
						(item isKindOf: GtAcpToolCall)
							ifTrue: [ contentContainer addChild: (GtAcpToolCallElement new toolCall: item) ] ] ] ].

	[ contentContainer children size > items size ] whileTrue: [
		contentContainer removeChildAt: contentContainer children size ]
]

{ #category : 'updating' }
GtAcpMessageElement >> updateRole [
	| roleName color |
	roleName := message role.
	color := roleName = 'user'
		ifTrue: [ BrGlamorousColors primaryBorderColor ]
		ifFalse: [ BrGlamorousColors successBackgroundColor ].
	roleElement text: (roleName asRopedText foreground: color)
]

{ #category : 'updating' }
GtAcpMessageElement >> updateThinking [
	thinkingElement ifNil: [ ^ self ].
	message hasThinking
		ifTrue: [
			thinkingElement message: message.
			thinkingElement visibility: BlVisibility visible ]
		ifFalse: [
			thinkingElement visibility: BlVisibility gone ]
]
