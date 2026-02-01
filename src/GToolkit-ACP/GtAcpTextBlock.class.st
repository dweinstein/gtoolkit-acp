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
	text := text
		ifNil: [ aString ]
		ifNotNil: [ text , aString ]
]

{ #category : 'gt views' }
GtAcpTextBlock >> gtTextFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Text';
		priority: 10;
		text: [ text ifNil: [ '' ] ]
]

{ #category : 'printing' }
GtAcpTextBlock >> printOn: aStream [
	aStream nextPutAll: 'GtAcpTextBlock('.
	text ifNotNil: [ 
		aStream nextPutAll: (text size > 40 
			ifTrue: [ (text first: 40) , '...' ]
			ifFalse: [ text ]) ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtAcpTextBlock >> text [
	^ text
]

{ #category : 'accessing' }
GtAcpTextBlock >> text: aString [
	text := aString
]
