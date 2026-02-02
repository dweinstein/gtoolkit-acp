Class {
	#name : 'GtAcpHomeSection',
	#superclass : 'GtHomeMultiCardSection',
	#category : 'GToolkit-ACP-UI',
	#package : 'GToolkit-ACP-UI'
}

{ #category : 'cards' }
GtAcpHomeSection >> acpShellCard [
	<gtSectionCard>
	| card |
	card := GtHomeCard explicit.
	^ card
		title: 'Claude Code';
		description: 'Browse and manage agent sessions';
		priority: 10;
		stencil: [
			| container titleLabel subtitleLabel |
			titleLabel := BrLabel new
				beLargeSize;
				padding: (BlInsets bottom: 5);
				aptitude: BrGlamorousLabelAptitude new bold;
				text: 'Claude Code'.
			subtitleLabel := BrLabel new
				aptitude: (BrGlamorousLabelAptitude new foreground: Color gray; fontSize: 12);
				text: 'Browse and manage agent sessions'.
			container := BrVerticalPane new
				exact: 250 @ 150;
				background: Color white;
				aptitude: BrShadowAptitude new beLarge
					+ (BrGlamorousButtonExteriorAptitude new
						backgroundPaint: Color white;
						borderPaint: Color transparent);
				padding: (BlInsets all: 15);
				margin: (BlInsets
					top: self spaceGap
					left: 2 * self spaceGap
					bottom: 2 * self spaceGap
					right: 2 * self spaceGap);
				when: BlClickEvent do: [ :anEvent |
					anEvent consumed: true.
					container phlow spawnOrShowObject: GtAcpClientRegistry uniqueInstance ].
			container addChild: titleLabel preventMeAndChildrenMouseEvents.
			container addChild: subtitleLabel preventMeAndChildrenMouseEvents.
			container ]
]

{ #category : 'accessing' }
GtAcpHomeSection >> sectionTitle [
	^ 'Agents'
]
