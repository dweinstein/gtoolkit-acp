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
			| container titleLabel subtitleLabel nodePathElement jsPathElement inspectArea pathsArea |
			titleLabel := BrLabel new
				beLargeSize;
				padding: (BlInsets bottom: 5);
				aptitude: BrGlamorousLabelAptitude new bold;
				text: 'Claude Code'.
			subtitleLabel := BrLabel new
				aptitude: (BrGlamorousLabelAptitude new foreground: Color gray; fontSize: 12);
				text: 'Browse and manage agent sessions'.

			nodePathElement := GtAcpFilePathElement new
				hMatchParent;
				label: 'Node:';
				path: GtClaudeCodeClient programPath asFileReference;
				onPathChanged: [ :aPathString |
					GtClaudeCodeClient programPath: aPathString ].

			jsPathElement := GtAcpFilePathElement new
				hMatchParent;
				label: 'ACP JS:';
				path: GtClaudeCodeClient programArgs first asFileReference;
				onPathChanged: [ :aPathString |
					GtClaudeCodeClient programArgs: { aPathString } ].

			inspectArea := BrVerticalPane new
				hMatchParent;
				vFitContent;
				when: BlClickEvent do: [ :anEvent |
					anEvent consumed: true.
					inspectArea phlow spawnOrShowObject: GtAcpClientRegistry uniqueInstance ].
			inspectArea addChild: titleLabel preventMeAndChildrenMouseEvents.
			inspectArea addChild: subtitleLabel preventMeAndChildrenMouseEvents.

			pathsArea := BrVerticalPane new
				hMatchParent;
				vFitContent;
				cellSpacing: 4;
				padding: (BlInsets top: 10);
				when: BlClickEvent do: [ :e | e consumed: true ];
				when: BlDoubleClickEvent do: [ :e | e consumed: true ];
				addChild: nodePathElement;
				addChild: jsPathElement.

			container := BrVerticalPane new
				exact: 400 @ 170;
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
					right: 2 * self spaceGap).
			container addChild: inspectArea.
			container addChild: pathsArea.
			container ]
]

{ #category : 'accessing' }
GtAcpHomeSection >> sectionTitle [
	^ 'Agents'
]
