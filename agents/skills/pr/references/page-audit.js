// Pass this file's text to preview_evaluate on each captured state; it returns what a reader would flag.
function auditPage() {
	const paint = document.createElement('canvas').getContext('2d', {willReadFrequently: true})

	function visible(element) {
		const rect = element.getBoundingClientRect()
		const style = getComputedStyle(element)
		// Screen-reader-only text measures 1 px.
		return rect.width > 1 && rect.height > 1 && style.visibility !== 'hidden' && style.opacity !== '0'
	}
	/** @returns {string} */
	function textOf(element) {
		return (element.innerText || '').trim().replaceAll(/\s+/gu, ' ')
	}
	function describe(element) {
		const slot = element.getAttribute('data-slot')
		const label = element.getAttribute('aria-label')
		const text = textOf(element).slice(0, 40)
		return [element.tagName.toLowerCase(), slot && `[${slot}]`, label && `"${label}"`, !label && text && `“${text}”`]
			.filter(Boolean)
			.join(' ')
	}
	function counted(values) {
		/** @type {Map<string, number>} */
		const counts = new Map()
		for (const value of values) counts.set(value, (counts.get(value) || 0) + 1)
		return [...counts.entries()].sort((left, right) => right[1] - left[1])
	}
	function repeated(values) {
		return counted(values)
			.filter(entry => entry[1] > 1)
			.slice(0, 15)
			.map(entry => `${entry[1]}× ${entry[0].slice(0, 40)}`)
	}
	function labelledBy(element) {
		return (element.getAttribute('aria-labelledby') || '')
			.split(' ')
			.map(id => document.getElementById(id))
			.filter(Boolean)
			.map(textOf)
			.join(' ')
	}
	function nameOf(element) {
		return (
			element.getAttribute('aria-label') ||
			labelledBy(element) ||
			[...(element.labels || [])].map(textOf).join(' ') ||
			textOf(element) ||
			element.getAttribute('title') ||
			element.getAttribute('placeholder') ||
			''
		)
	}
	// A control stretched over its whole parent, the way a row that opens its content is built.
	function overlay(element) {
		const rect = element.getBoundingClientRect()
		const parent = element.parentElement.getBoundingClientRect()
		return (
			getComputedStyle(element).position === 'absolute' &&
			rect.width * rect.height >= parent.width * parent.height * 0.9
		)
	}
	function overlapping(first, second) {
		if (first.contains(second) || second.contains(first) || overlay(first) || overlay(second)) return false
		const a = first.getBoundingClientRect()
		const b = second.getBoundingClientRect()
		const overlapX = Math.min(a.right, b.right) - Math.max(a.left, b.left)
		const overlapY = Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top)
		return overlapX > 2 && overlapY > 2
	}
	function regionOf(element) {
		return (
			element.closest('[role="region"], [role="dialog"], section, article, main, [data-slot="card"]') || document.body
		)
	}
	// Any CSS color, oklch included, as sRGB channels 0–255 and alpha 0–1.
	function channels(color) {
		paint.clearRect(0, 0, 1, 1)
		paint.fillStyle = color
		paint.fillRect(0, 0, 1, 1)
		const pixel = paint.getImageData(0, 0, 1, 1).data
		return [pixel[0], pixel[1], pixel[2], pixel[3] / 255]
	}
	function over(top, bottom) {
		return [0, 1, 2].map(index => top[index] * top[3] + bottom[index] * (1 - top[3]))
	}
	// The opaque color behind an element: every ancestor's background composited from the root down onto white.
	function backdrop(element) {
		if (!element) return [255, 255, 255]
		return over(channels(getComputedStyle(element).backgroundColor), backdrop(element.parentElement))
	}
	function luminance(rgb) {
		const linear = rgb.map(value => {
			const unit = value / 255
			if (unit <= 0.04045) return unit / 12.92
			return ((unit + 0.055) / 1.055) ** 2.4
		})
		return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
	}
	function ratio(first, second) {
		return (Math.max(first, second) + 0.05) / (Math.min(first, second) + 0.05)
	}
	function contrast(element) {
		const behind = backdrop(element)
		return ratio(luminance(over(channels(getComputedStyle(element).color), behind)), luminance(behind))
	}
	function large(element) {
		const style = getComputedStyle(element)
		const size = Number.parseFloat(style.fontSize)
		return size >= 24 || (size >= 18.66 && Number.parseInt(style.fontWeight, 10) >= 700)
	}
	function ring(element) {
		const style = getComputedStyle(element)
		return `${style.outlineStyle} ${style.outlineWidth} ${style.outlineColor} ${style.boxShadow} ${style.borderColor}`
	}
	// Children of one row that sit 1–4 px off each other's centre, or of one column off each other's left edge.
	/** @param {Element} container */
	function offBy(container) {
		const style = getComputedStyle(container)
		const children = [...container.children].filter(
			child => visible(child) && getComputedStyle(child).position !== 'absolute'
		)
		if (!style.display.includes('flex') || style.flexWrap !== 'nowrap' || children.length < 2) return 0
		const edges = children.map(child => {
			const rect = child.getBoundingClientRect()
			if (style.flexDirection.startsWith('row')) return rect.top + rect.height / 2
			return rect.left
		})
		const spread = Math.max(...edges) - Math.min(...edges)
		if (style.flexDirection.startsWith('column') && style.alignItems !== 'flex-start' && style.alignItems !== 'start') {
			return 0
		}
		if (spread >= 1 && spread <= 4) return Math.round(spread * 10) / 10
		return 0
	}

	// OKLCH lightness 0–1, chroma and hue in degrees, from sRGB channels.
	function oklch(rgb) {
		const linear = rgb.slice(0, 3).map(value => {
			const unit = value / 255
			if (unit <= 0.04045) return unit / 12.92
			return ((unit + 0.055) / 1.055) ** 2.4
		})
		const cone = [
			0.4122 * linear[0] + 0.5363 * linear[1] + 0.0514 * linear[2],
			0.2119 * linear[0] + 0.6807 * linear[1] + 0.1074 * linear[2],
			0.0883 * linear[0] + 0.2817 * linear[1] + 0.63 * linear[2]
		].map(Math.cbrt)
		const a = 1.978 * cone[0] - 2.4286 * cone[1] + 0.4506 * cone[2]
		const b = 0.0259 * cone[0] + 0.7828 * cone[1] - 0.8087 * cone[2]
		return {
			chroma: Math.hypot(a, b),
			hue: (Math.atan2(b, a) * 180) / Math.PI + 360 * Number(b < 0),
			lightness: 0.2105 * cone[0] + 0.7936 * cone[1] - 0.0041 * cone[2]
		}
	}
	function tinted(color) {
		const rgba = channels(color)
		return rgba[3] > 0 && oklch(rgba).chroma > 0.03
	}
	// Every custom property the page's own stylesheets declare, nested layers and media rules included.
	function declared(rules) {
		return [...rules].flatMap(rule => [
			...[...(rule.style || [])].filter(name => name.startsWith('--')),
			...declared(rule.cssRules || [])
		])
	}
	function themeValues() {
		const names = new Set(
			[...document.styleSheets]
				.filter(sheet => !sheet.href || new URL(sheet.href).origin === location.origin)
				.flatMap(sheet => declared(sheet.cssRules))
		)
		return [...names].map(name => getComputedStyle(document.documentElement).getPropertyValue(name).trim())
	}
	// The theme's radii in px, resolved through a probe so rem and calc() values count.
	function themeRadii(values) {
		const probe = document.body.appendChild(document.createElement('div'))
		const radii = values
			.filter(value => CSS.supports('border-radius', value) && !CSS.supports('color', value))
			.map(value => {
				probe.style.borderRadius = value
				return Number.parseFloat(getComputedStyle(probe).borderTopLeftRadius)
			})
		probe.remove()
		return new Set([0, ...radii.filter(Number.isFinite)])
	}
	function offPalette(color, palette) {
		const rgba = channels(color)
		if (rgba[3] === 0 || palette.length === 0) return false
		// Low alpha loses channel precision on the round trip through the canvas.
		const tolerance = 10 / Math.max(rgba[3], 0.1)
		return palette.every(
			token => Math.abs(token[0] - rgba[0]) + Math.abs(token[1] - rgba[1]) + Math.abs(token[2] - rgba[2]) > tolerance
		)
	}
	// Lines of text an element wraps to: line boxes whose tops sit more than half a line apart.
	function lineCount(element) {
		const range = document.createRange()
		range.selectNodeContents(element)
		const tops = [...range.getClientRects()]
			.filter(rect => rect.width > 1)
			.map(rect => rect.top)
			.sort((first, second) => first - second)
		const half = Number.parseFloat(getComputedStyle(element).fontSize) * 0.6
		return tops.filter((top, index) => index === 0 || top - tops[index - 1] > half).length
	}
	function drift(elements) {
		const looks = new Map()
		for (const element of elements) {
			const style = getComputedStyle(element)
			const key = [
				element.getAttribute('data-slot'),
				element.getAttribute('data-variant'),
				element.getAttribute('data-size')
			]
				.filter(Boolean)
				.join('/')
			const look = `h${Math.round(element.getBoundingClientRect().height)} ${style.fontSize} r${style.borderTopLeftRadius} px${style.paddingLeft}`
			looks.set(key, new Set([...(looks.get(key) || []), look]))
		}
		return [...looks.entries()]
			.filter(entry => entry[1].size > 1)
			.map(entry => `${entry[0]}: ${[...entry[1]].join(' | ')}`)
	}

	const all = [...document.querySelectorAll('body *')].filter(visible)
	const controls = all.filter(element =>
		element.matches('button, a[href], [role="button"], [role="menuitem"], [role="tab"], input, select, textarea')
	)
	const enabled = controls.filter(element => !element.closest('[disabled], [aria-disabled="true"], [inert]'))
	const loaders = all.filter(element =>
		element.matches('[aria-busy="true"], [data-slot="skeleton"], [role="progressbar"]')
	)
	const errors = all.filter(element =>
		element.matches('[role="alert"], [data-slot="alert"][data-variant="destructive"]')
	)
	const texts = all.filter(element => element.children.length === 0 && textOf(element).length > 1)
	const styled = all.filter(element => {
		const style = getComputedStyle(element)
		return channels(style.backgroundColor)[3] > 0 || Number.parseFloat(style.borderTopWidth) > 0
	})
	const theme = themeValues()
	const palette = theme
		.filter(value => CSS.supports('color', value))
		.map(channels)
		.filter(rgba => rgba[3] > 0)
	const radii = themeRadii(theme)
	const bodyFont = getComputedStyle(document.body).fontFamily.split(',')[0].trim()
	const selected = all.filter(element =>
		element.matches(
			'[aria-selected="true"], [aria-current]:not([aria-current="false"]), [aria-checked="true"], [data-state="active"], [data-state="on"], [data-selected="true"]'
		)
	)
	// The Design section of Deslop's AGENTS.md, measured; outside Deslop this group is informational.
	const design = {
		brightBarButton: all
			.filter(element => element.matches('header button, [data-slot="app-bar"] button, nav button'))
			.filter(element => {
				const color = oklch(channels(getComputedStyle(element).backgroundColor))
				return (
					channels(getComputedStyle(element).backgroundColor)[3] > 0.5 && color.chroma > 0.08 && color.lightness > 0.5
				)
			})
			.map(describe),
		columnHeadings: all.filter(element => element.matches('th, [role="columnheader"]')).map(describe),
		countInHeading: all
			.filter(element => element.matches('h1, h2, h3, h4, h5, h6, [role="tab"], [data-slot="tabs-trigger"]'))
			.filter(element => /\(\d+\)|\s\d+$/u.test(textOf(element)))
			.map(describe),
		emptyText: all
			.filter(element => element.matches('[data-slot="empty-title"], [data-slot="empty-description"]'))
			.map(describe),
		green: all
			.filter(element =>
				[getComputedStyle(element).color, getComputedStyle(element).backgroundColor].some(color => {
					const rgba = channels(color)
					const value = oklch(rgba)
					return rgba[3] > 0 && value.chroma > 0.06 && value.hue > 120 && value.hue < 165
				})
			)
			.filter(element => element.children.length === 0 || channels(getComputedStyle(element).backgroundColor)[3] > 0)
			.slice(0, 15)
			.map(describe),
		longLines: all
			.filter(element => element.matches('p, li, [data-slot$="description"]') && textOf(element).length > 120)
			.filter(element => textOf(element).length / Math.max(lineCount(element), 1) > 90)
			.map(describe),
		lucideIcons: document.querySelectorAll('svg.lucide, svg[class*="lucide-"]').length,
		multiLineRows: all
			.filter(element =>
				element.matches(
					'[role="row"], [role="option"], [role="menuitem"], [data-slot="item"], [data-slot="command-item"], [role="list"] > li, [role="listbox"] > *'
				)
			)
			.filter(element => lineCount(element) > 1)
			.slice(0, 15)
			.map(describe),
		pressScale: [...document.querySelectorAll('[class*="active:scale"], [class*="active:translate"]')].map(describe),
		proportionalFigures: texts
			.filter(element =>
				/^[\d\s:.,%+\-−×/]+$|\b\d{1,3}(\.\d{1,3}){3}\b|\b[0-9a-f]{7,40}\b|\b\d+(ms|s|m|h|d|KB|MB|GB|%)\b|\b\d{1,2}:\d{2}\b/u.test(
					textOf(element)
				)
			)
			// Inside a shadcn component a figure takes the component's own font; table cells and running text do not.
			.filter(element => !element.closest('[data-slot]:not([data-slot^="table"])'))
			.filter(element => {
				const style = getComputedStyle(element)
				return !style.fontVariantNumeric.includes('tabular-nums') && !/mono/iu.test(style.fontFamily)
			})
			.slice(0, 15)
			.map(describe),
		rawError: all
			.filter(element => element.matches('[role="alert"], [data-slot="alert"], [data-slot="empty"]'))
			.filter(
				element =>
					textOf(element).length > 160 || /Error:|Cause|FiberFailure|_tag|\bat \S+:\d+|\{"/u.test(textOf(element))
			)
			.map(describe),
		// A rounded row whose own top or bottom border draws the line between rows.
		roundedDivider: all
			.filter(element => element.matches('[role="row"], [role="option"], [data-slot="item"], tr, li'))
			.filter(element => {
				const style = getComputedStyle(element)
				const sides = [style.borderLeftWidth, style.borderRightWidth].map(Number.parseFloat)
				const rows = [style.borderTopWidth, style.borderBottomWidth].map(Number.parseFloat)
				return (
					Number.parseFloat(style.borderTopLeftRadius) > 0 &&
					sides.every(width => width === 0) &&
					rows.some(width => width > 0)
				)
			})
			.map(describe),
		spinner: all
			// A progress bar with a value measures something; one without is a loading indicator.
			.filter(element =>
				element.matches('.animate-spin, [data-slot="spinner"], [role="progressbar"]:not([aria-valuenow])')
			)
			.filter(element => !element.closest('button'))
			.map(describe),
		tintedSelection: selected.filter(element => tinted(getComputedStyle(element).backgroundColor)).map(describe),
		tintedSurface: all
			.filter(element => {
				const rect = element.getBoundingClientRect()
				return rect.width * rect.height > innerWidth * innerHeight * 0.15
			})
			.filter(element => tinted(getComputedStyle(element).backgroundColor))
			.map(describe)
	}
	// Each off-theme color with how often it appears and one element that uses it.
	function offColors(elements) {
		/** @type {Map<string, {count: number, example: string}>} */
		const found = new Map()
		for (const element of elements) {
			const style = getComputedStyle(element)
			const used = [
				[style.color, element.children.length === 0 && textOf(element)],
				[style.backgroundColor, true],
				[style.borderTopColor, Number.parseFloat(style.borderTopWidth) > 0]
			]
			for (const entry of used.filter(candidate => candidate[1] && offPalette(candidate[0], palette))) {
				found.set(entry[0], {count: (found.get(entry[0])?.count || 0) + 1, example: describe(element)})
			}
		}
		return [...found.entries()]
			.sort((left, right) => right[1].count - left[1].count)
			.slice(0, 15)
			.map(entry => `${entry[1].count}× ${entry[0]}, e.g. ${entry[1].example}`)
	}
	// Focuses each control as the keyboard would, then hands focus back to whatever held it.
	function ringless(elements, previous) {
		const missing = elements.filter(element => {
			const resting = ring(element)
			element.focus({focusVisible: true, preventScroll: true})
			const shown = document.activeElement !== element || ring(element) !== resting
			element.blur()
			return !shown
		})
		if (previous instanceof HTMLElement) previous.focus({preventScroll: true})
		return missing
	}

	return {
		brokenImages: [...document.images]
			.filter(image => image.complete && image.naturalWidth === 0)
			.map(image => image.src),
		// A shadcn component of one slot, variant and size that renders at more than one height, type size, radius or padding was restyled somewhere.
		componentDrift: drift(
			all.filter(element => element.hasAttribute('data-slot') && element.getBoundingClientRect().height <= 64)
		),
		cut: all
			.filter(element => {
				const style = getComputedStyle(element)
				const clipsX =
					(['hidden', 'clip'].includes(style.overflowX) || style.textOverflow === 'ellipsis') &&
					element.scrollWidth > element.clientWidth + 1
				const clipsY = ['hidden', 'clip'].includes(style.overflowY) && element.scrollHeight > element.clientHeight + 1
				return (clipsX || clipsY) && textOf(element)
			})
			.map(describe),
		design,
		errorWhileLoading: errors
			.filter(
				error =>
					error.closest('[aria-busy="true"]') ||
					loaders.some(loader => regionOf(loader.parentElement || loader) === regionOf(error))
			)
			.map(describe),
		errors: errors.map(describe),
		// Every type size and corner radius on the page with its count; a size or radius used once or twice is usually a one-off.
		fontSizes: counted(texts.map(element => getComputedStyle(element).fontSize)).map(
			entry => `${entry[0]}×${entry[1]}`
		),
		lowContrast: texts
			.filter(element => !element.closest('[disabled], [aria-disabled="true"]'))
			.filter(element => contrast(element) < 3 || (!large(element) && contrast(element) < 4.5))
			.slice(0, 15)
			.map(element => `${describe(element)} ${contrast(element).toFixed(1)}:1`),
		misaligned: all
			.filter(element => offBy(element) > 0)
			.slice(0, 15)
			.map(element => `${describe(element)} off by ${offBy(element)}px`),
		noFocusRing: ringless(enabled.slice(0, 80), document.activeElement).map(describe),
		// Text in another family than the body's, monospace aside.
		offFont: texts
			.filter(element => {
				const family = getComputedStyle(element).fontFamily
				return !family.startsWith(bodyFont) && !/mono/iu.test(family) && !element.closest('code, pre, kbd, svg')
			})
			.slice(0, 15)
			.map(element => `${describe(element)} ${getComputedStyle(element).fontFamily.split(',')[0]}`),
		// Text, fill and border colors that match none of the theme's tokens: a raw color or a restyle.
		offPalette: offColors(all.filter(element => !element.closest('svg, img, picture, video, canvas'))),
		// Corners outside the theme's radii, circles aside.
		offRadius: styled
			.filter(element => {
				const rect = element.getBoundingClientRect()
				const radius = Number.parseFloat(getComputedStyle(element).borderTopLeftRadius)
				return radii.size > 1 && !radii.has(radius) && radius * 2 < Math.min(rect.width, rect.height) - 1
			})
			.slice(0, 15)
			.map(element => `${describe(element)} ${getComputedStyle(element).borderTopLeftRadius}`),
		overlaps: controls
			.flatMap((first, index) =>
				controls
					.slice(index + 1)
					.filter(second => overlapping(first, second))
					.map(second => `${describe(first)} ↔ ${describe(second)}`)
			)
			.slice(0, 15),
		pageOverflow: Math.max(0, document.documentElement.scrollWidth - innerWidth),
		repeatedActions: repeated(controls.map(nameOf).filter(Boolean)),
		repeatedText: repeated(texts.map(textOf)),
		smallTargets: enabled
			.filter(() => innerWidth < 640)
			.filter(element => !(element.matches('a') && textOf(element.parentElement).length > textOf(element).length + 1))
			.filter(element => element.getBoundingClientRect().width < 44 || element.getBoundingClientRect().height < 44)
			.slice(0, 15)
			.map(element => {
				const rect = element.getBoundingClientRect()
				return `${describe(element)} ${Math.round(rect.width)}×${Math.round(rect.height)}`
			}),
		// Key caps ship small by design.
		tinyText: texts
			.filter(element => !element.closest('kbd, [data-slot="kbd"]'))
			.filter(element => Number.parseFloat(getComputedStyle(element).fontSize) < 12)
			.map(describe),
		unnamed: controls.filter(element => !nameOf(element)).map(describe),
		viewport: `${innerWidth}×${innerHeight}`
	}
}
auditPage()
