## 7.1.1

 - **REFACTOR**: reorganise thrown exceptions ([#63](https://github.com/jaspervanriet/duck_router/issues/63)). ([85f0ac78](https://github.com/jaspervanriet/duck_router/commit/85f0ac78c2cca58240f9fe77220fa90eb24b8a91))

## 7.1.0

 - **FEAT**: expose DuckRouterException ([#62](https://github.com/jaspervanriet/duck_router/issues/62)). ([44530747](https://github.com/jaspervanriet/duck_router/commit/4453074700f69ff51b963d6c82b7542a4cbfa044))

## 7.0.1

 - **FIX**: typo. ([269eed92](https://github.com/jaspervanriet/duck_router/commit/269eed921b33a272c97bcc1457721dd6835ad1ef))

## 7.0.0

> Note: This release has breaking changes.

 - **REFACTOR**: deprecate `popRoot` for `exit` ([#60](https://github.com/jaspervanriet/duck_router/issues/60)). ([4153041e](https://github.com/jaspervanriet/duck_router/commit/4153041e4d917d921741a8c4bcae631ae16f8ba1))
 - **FEAT**: support WidgetsApp ([#61](https://github.com/jaspervanriet/duck_router/issues/61)). ([b92335a5](https://github.com/jaspervanriet/duck_router/commit/b92335a5d45955f073b66a2085626eea35c214c8))
 - **REFACTOR**: tighten up internal classes ([#59](https://github.com/jaspervanriet/duck_router/issues/59)). ([b2642a04](https://github.com/jaspervanriet/duck_router/commit/b2642a04ec6f7ba995ae7b183fe5a5137afb7514))
 - **BREAKING** **FEAT**: flow locations. Easily create modal flows (and other use cases) using `FlowLocation`, a convenience class on top of `StatefulLocation`. This PR also aims to make the interface for `StatefulLocation` more intutive. This can require changes for certain advanced usages of `StatefulLocation`, please see the migration guide in the PR. ([#57](https://github.com/jaspervanriet/duck_router/issues/57)). ([15c2396e](https://github.com/jaspervanriet/duck_router/commit/15c2396e1dfc012ad17af655c77146d79d728723))

## 6.2.2

 - **DOCS**: describe more details on nested navigation ([#55](https://github.com/jaspervanriet/duck_router/issues/55)). ([de267992](https://github.com/jaspervanriet/duck_router/commit/de2679925be0335fcae327e2e9a41972e85de493))

## 6.2.1

 - **FIX**: throw exception to listeners if clearStack is used ([#54](https://github.com/jaspervanriet/duck_router/issues/54)). ([a8dd9090](https://github.com/jaspervanriet/duck_router/commit/a8dd9090398d7439ee06381ea4a4c2f165837ea8))

## 6.2.0

 - **FEAT**: allow popping root via popRoot ([#53](https://github.com/jaspervanriet/duck_router/issues/53)). ([4d15f301](https://github.com/jaspervanriet/duck_router/commit/4d15f30115ac684dd7a45ccb56368e0602ded909))

## 6.1.0

 - **FIX**: outdated documentation ([#49](https://github.com/jaspervanriet/duck_router/issues/49)). ([3179792c](https://github.com/jaspervanriet/duck_router/commit/3179792c2a9a1d6e0bad132afddf185984936cdb))
 - **FEAT**: allow awaiting a page that gets replaced ([#50](https://github.com/jaspervanriet/duck_router/issues/50)). ([256e2820](https://github.com/jaspervanriet/duck_router/commit/256e28203009b4efc1cba568e3b141d04c26085f))

## 6.0.1

 - **FIX**: updates `README.md` to use `path` override ([#46](https://github.com/jaspervanriet/duck_router/issues/46)). ([04128719](https://github.com/jaspervanriet/duck_router/commit/041287198cebe3a242fc1633f9d14b63cafaf9cf))

## 6.0.0

> Note: This release has breaking changes.

**Breaking changes**:

- There has been a breaking change in the syntax for `DuckPage`. There is no functionality difference.
- `DuckPage` no longer needs a `name` parameter and the interface for `DuckPage.createRoute` has changed, see [#44](https://github.com/JaspervanRiet/duck_router/pull/44) for a migration guide and reasoning.

- **FIX**: link to custom pages. ([ae2a8715](https://github.com/jaspervanriet/duck_router/commit/ae2a87151276be7f783c3c690c4d0c52e4523e16))
- **FIX**: typo. ([5390c2bb](https://github.com/jaspervanriet/duck_router/commit/5390c2bbb9cdb27bcd5bbd1531ed2d874706e797))
- **BREAKING** **FIX**: allow awaiting custom page navigation ([#44](https://github.com/JaspervanRiet/duck_router/pull/44)). ([96d9c459](https://github.com/jaspervanriet/duck_router/commit/96d9c4591d1660ded3328fbec4372c1b73adfb6e))

## 5.4.0

- **FIX**: generate documentation categories correctly. ([174b9b27](https://github.com/jaspervanriet/duck_router/commit/174b9b2701d0e269396d4b83ab4c2526b37902e0))
- **FEAT**: add library level comment. ([8a6baa0c](https://github.com/jaspervanriet/duck_router/commit/8a6baa0c618dedd94f66624b23ff214e78d32076))

## 5.3.0

- **FEAT**: add support for extra documentation. ([0b5befe1](https://github.com/jaspervanriet/duck_router/commit/0b5befe165f47bdf2245e04e98ca86fe63674278))

## 5.2.0

- **FEAT**: add support for NavigatorObservers ([#35](https://github.com/jaspervanriet/duck_router/issues/35)). ([616aefbb](https://github.com/jaspervanriet/duck_router/commit/616aefbbef9d40c86d99173399bad64c80661ccd))

## 5.1.3

- **FIX**: allow comparison of LocationStack. ([a0f83e2f](https://github.com/jaspervanriet/duck_router/commit/a0f83e2f39eda4597bb658c239037c991c70ea33))
- **FIX**: router errors when restoring state ([#41](https://github.com/jaspervanriet/duck_router/issues/41)). ([879a8863](https://github.com/jaspervanriet/duck_router/commit/879a8863cdc07b3c1dd934e0e822e291f9198d24))

## 5.1.2

- **DOCS**: improve README to highlight philosophy. ([6b871e00](https://github.com/jaspervanriet/duck_router/commit/6b871e0079eaa60f6baf0585e0800a1963993a31))

## 5.1.1

- **DOCS**: update package README ([#39](https://github.com/jaspervanriet/duck_router/issues/39)). ([f0c40c3b](https://github.com/jaspervanriet/duck_router/commit/f0c40c3b8d4a48a70928d4033fb1a0e91606c2ac))
- **DOCS**: add example with params to README ([#38](https://github.com/jaspervanriet/duck_router/issues/38)). ([bf16a0b5](https://github.com/jaspervanriet/duck_router/commit/bf16a0b554e0fb132a912b0090be09d60823dc91))

## 5.1.0

- **FEAT**: feat: add support for fire-and-forget deeplink handling ([#32](https://github.com/Jaspervanriet/duck_router/issues/32)). ([728a9a69](https://github.com/jaspervanriet/duck_router/commit/735121018a2754334136d7773d01039903779867))

## 5.0.0

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: remove need to specify onPopInvoked ([#31](https://github.com/jaspervanriet/duck_router/issues/31)). ([dffbfc86](https://github.com/jaspervanriet/duck_router/commit/dffbfc8645078acb16dfa4534227342b28fbbb3b)). Please see the README for how to create custom pages.

## 4.0.0

> Note: This release has breaking changes.

- **FIX**: typo. ([28c3812b](https://github.com/jaspervanriet/duck_router/commit/28c3812b6e0b71619e1f1f5ae5ecb3952eca080a))
- **BREAKING** **FEAT**: migrate to onDidRemovePage ([#28](https://github.com/jaspervanriet/duck_router/issues/28)). ([0f2cf6ac](https://github.com/jaspervanriet/duck_router/commit/0f2cf6ac6a19214445feed2e5881f815219662df))

## 3.0.0

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: use Location Type for popUntil ([#25](https://github.com/jaspervanriet/duck_router/issues/25)). ([ea2ff70d](https://github.com/jaspervanriet/duck_router/commit/ea2ff70d447915eff4ddb71b2a4093bfdede665f))

## 2.2.0

- **FEAT**: add clear stack ([#22](https://github.com/jaspervanriet/duck_router/issues/22)). ([728a9a69](https://github.com/jaspervanriet/duck_router/commit/728a9a6919b724734cc1be739d425f1d6092563e))
- **FEAT**: allow popping from a nested flow ([#20](https://github.com/jaspervanriet/duck_router/issues/20)). ([ccedcbf2](https://github.com/jaspervanriet/duck_router/commit/ccedcbf217ce3775b68cd124642c58a4ce6b198c))

## 2.1.0

- **FEAT**: revert removal of root() ([#19](https://github.com/jaspervanriet/duck_router/issues/19)). ([23b862f3](https://github.com/jaspervanriet/duck_router/commit/23b862f3bc613d24632a89c3cf915f5dd9fdfbed))

## 2.0.0

> Note: This release has breaking changes.

- **FEAT**: create CONTRIBUTING.md ([#12](https://github.com/jaspervanriet/duck_router/issues/12)). ([64f92e11](https://github.com/jaspervanriet/duck_router/commit/64f92e11296459892afbf2247e4779524715a7e3))
- **FEAT**: create DuckPage ([#10](https://github.com/jaspervanriet/duck_router/issues/10)). ([fdc1e56e](https://github.com/jaspervanriet/duck_router/commit/fdc1e56eb22a249e582208b9955d311d64faa03b))
- **BREAKING** **FEAT**: remove StatefulChildLocation ([#15](https://github.com/jaspervanriet/duck_router/issues/15)). ([6ab34175](https://github.com/jaspervanriet/duck_router/commit/6ab3417519c15021d3d0cd2b318499a994337c90))
- **BREAKING** **FEAT**: replace root() with popUntil ([#14](https://github.com/jaspervanriet/duck_router/issues/14)). ([df5e6639](https://github.com/jaspervanriet/duck_router/commit/df5e66393366a7d729c27c2f4b057e734ece6ea4))

## 1.1.0

- **FIX**: child back button dispatcher ([#8](https://github.com/jaspervanriet/duck_router/issues/8)). ([a8cba916](https://github.com/jaspervanriet/duck_router/commit/a8cba916b7b4037d6ef80909bcb3af3ba435b2e7))
- **FEAT**: catch case where users pushes duplicate path ([#9](https://github.com/jaspervanriet/duck_router/issues/9)). ([5a504661](https://github.com/jaspervanriet/duck_router/commit/5a504661770c19b9108e922e4c9a2b67f8a47002))

## 1.0.1

- **FIX**: add code highlighting to README. ([071845a2](https://github.com/jaspervanriet/duck_router/commit/071845a299341f7338c0785095039d749d80f19f))

## 1.0.0

- Initial release

- **FEAT**: get pubspec ready for release. ([800d38e2](https://github.com/jaspervanriet/duck_router/commit/800d38e2b0e5387f69dd5df8f880c618dee408b9))
- **FEAT**: set up base structure for repo. ([0e00d975](https://github.com/jaspervanriet/duck_router/commit/0e00d97510bd602b8dadd8c4555d2ac3d29014d9))
