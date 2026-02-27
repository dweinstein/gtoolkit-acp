Class {
	#name : 'GtAcpTextBlock',
	#superclass : 'GtAcpContentBlock',
	#instVars : [
		'text'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpTextBlock class >> fromDictionary: aDictionary [
	^ self new
		metadata: aDictionary;
		text: (aDictionary at: 'text' ifAbsent: [ '' ]);
		yourself
]

{ #category : 'accessing' }
GtAcpTextBlock >> appendText: aString [
	| delta current |
	delta := aString ifNil: [ '' ] ifNotNil: [ aString asString ].
	delta isEmpty ifTrue: [ ^ self ].
	current := text ifNil: [ '' ] ifNotNil: [ text asString ].
	text := current , delta
]

{ #category : 'gt views' }
GtAcpTextBlock >> gtTextFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Text';
		priority: 10;
		text: [ self text ]
]

{ #category : 'printing' }
GtAcpTextBlock >> printOn: aStream [
	| display |
	display := self text.
	aStream nextPutAll: 'GtAcpTextBlock('.
	display ifNotNil: [
		aStream nextPutAll: (display size > 40
			ifTrue: [ (display first: 40) , '...' ]
			ifFalse: [ display ]) ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtAcpTextBlock >> ropedText [
	^ self text asRopedText
]

{ #category : 'accessing' }
GtAcpTextBlock >> text [
	^ text ifNil: [ '' ] ifNotNil: [ text asString ]
]

{ #category : 'accessing' }
GtAcpTextBlock >> text: aString [
	text := aString ifNil: [ '' ] ifNotNil: [ aString asString ]
]
