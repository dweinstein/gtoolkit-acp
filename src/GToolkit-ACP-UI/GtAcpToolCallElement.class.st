Class {
	#name : 'GtAcpToolCallElement',
	#superclass : 'BlElement',
	#instVars : [
		'toolCall',
		'headerElement',
		'statusIcon',
		'titleLabel'
	],
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'initialization' }
GtAcpToolCallElement >> initialize [
	super initialize.
	self layout: BlLinearLayout horizontal alignCenterLeft.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical fitContent ].
	self padding: (BlInsets top: 2 bottom: 2 left: 8 right: 8).
	self margin: (BlInsets top: 2 bottom: 2).
	self background: (Color veryLightGray alpha: 0.2).
	self border: (BlBorder paint: (Color gray alpha: 0.3) width: 1).
	self when: BlClickEvent do: [ :e | 
		e consumed: true.
		self phlow spawnOrShowObject: toolCall ].
	statusIcon := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 12);
		text: '...';
		margin: (BlInsets right: 6).
	titleLabel := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 11; foreground: Color darkGray);
		hMatchParent;
		vFitContent.
	self addChild: statusIcon.
	self addChild: titleLabel
]

{ #category : 'accessing' }
GtAcpToolCallElement >> toolCall: aGtAcpToolCall [
	toolCall := aGtAcpToolCall.
	self update
]

{ #category : 'updating' }
GtAcpToolCallElement >> update [
	| icon |
	titleLabel text: (toolCall title ifNil: [ 'Tool call' ]).
	icon := toolCall status = 'completed'
		ifTrue: [ '+' ]
		ifFalse: [ toolCall status = 'failed'
			ifTrue: [ 'x' ]
			ifFalse: [ '...' ] ].
	statusIcon text: icon
]
