" Vim completion script
" Language:	CSS 3
" Maintainer:	othree ( othree AT gmail DOT com )
" Maintainer:	Mikolaj Machowski ( mikmach AT wp DOT pl )
" Last Change:	2015 Dec 25

let s:values = split("additive-symbols align-content align-items align-self animation animation-delay animation-direction animation-duration animation-fill-mode animation-iteration-count animation-name animation-play-state animation-timing-function backface-visibility background background-attachment background-blend-mode background-clip background-color background-image background-origin background-position background-repeat background-size block-size border border-block-end border-block-end-color border-block-end-style border-block-end-width border-block-start border-block-start-color border-block-start-style border-block-start-width border-bottom border-bottom-color border-bottom-left-radius border-bottom-right-radius border-bottom-style border-bottom-width border-collapse border-color border-image border-image-outset border-image-repeat border-image-slice border-image-source border-image-width border-inline-end border-inline-end-color border-inline-end-style border-inline-end-width border-inline-start border-inline-start-color border-inline-start-style border-inline-start-width border-left border-left-color border-left-style border-left-width border-radius border-right border-right-color border-right-style border-right-width border-spacing border-style border-top border-top-color border-top-left-radius border-top-right-radius border-top-style border-top-width border-width bottom box-decoration-break box-shadow box-sizing break-after break-before break-inside caption-side clear clip clip-path color columns column-count column-fill column-gap column-rule column-rule-color column-rule-style column-rule-width column-span column-width content counter-increment counter-reset cursor direction display empty-cells fallback filter flex flex-basis flex-direction flex-flow flex-grow flex-shrink flex-wrap float font font-family font-feature-settings font-kerning font-language-override font-size font-size-adjust font-stretch font-style font-synthesis font-variant font-variant-alternates font-variant-caps font-variant-east-asian font-variant-ligatures font-variant-numeric font-variant-position font-weight grid grid-area grid-auto-columns grid-auto-flow grid-auto-position grid-auto-rows grid-column grid-column-start grid-column-end grid-row grid-row-start grid-row-end grid-template grid-template-areas grid-template-rows grid-template-columns height hyphens image-rendering image-resolution image-orientation ime-mode inline-size isolation justify-content left letter-spacing line-break line-height list-style list-style-image list-style-position list-style-type margin margin-block-end margin-block-start margin-bottom margin-inline-end margin-inline-start margin-left margin-right margin-top marks mask mask-type max-block-size max-height max-inline-size max-width max-zoom min-block-size min-height min-inline-size min-width min-zoom mix-blend-mode negative object-fit object-position offset-block-end offset-block-start offset-inline-end offset-inline-start opacity order orientation orphans outline outline-color outline-offset outline-style outline-width overflow overflow-wrap overflow-x overflow-y pad padding padding-block-end padding-block-start padding-bottom padding-inline-end padding-inline-start padding-left padding-right padding-top page-break-after page-break-before page-break-inside perspective perspective-origin pointer-events position prefix quotes range resize right ruby-align ruby-merge ruby-position scroll-behavior scroll-snap-coordinate scroll-snap-destination scroll-snap-points-x scroll-snap-points-y scroll-snap-type scroll-snap-type-x scroll-snap-type-y shape-image-threshold shape-margin shape-outside speak-as suffix symbols system table-layout tab-size text-align text-align-last text-combine-upright text-decoration text-decoration-color text-decoration-line text-emphasis text-emphasis-color text-emphasis-position text-emphasis-style text-indent text-orientation text-overflow text-rendering text-shadow text-transform text-underline-position top touch-action transform transform-box transform-origin transform-style transition transition-delay transition-duration transition-property transition-timing-function unicode-bidi unicode-range user-zoom vertical-align visibility white-space widows width will-change word-break word-spacing word-wrap writing-mode z-index zoom")


function! csscomplete#CompleteCSS(findstart, base)

  if a:findstart
    " We need whole line to proper checking
    let line = getline('.')
    let start = col('.') - 1
    let compl_begin = col('.') - 2
    while start >= 0 && line[start - 1] =~ '\%(\k\|-\)'
      let start -= 1
    endwhile
    let b:compl_context = line[0:compl_begin]
    return start
  endif

  " There are few chars important for context:
  " ^ ; : { } /* */
  " Where ^ is start of line and /* */ are comment borders
  " Depending on their relative position to cursor we will know what should
  " be completed. 
  " 1. if nearest are ^ or { or ; current word is property
  " 2. if : it is value (with exception of pseudo things)
  " 3. if } we are outside of css definitions
  " 4. for comments ignoring is be the easiest but assume they are the same
  "    as 1. 
  " 5. if @ complete at-rule
  " 6. if ! complete important
  if exists("b:compl_context")
    let line = b:compl_context
    unlet! b:compl_context
  else
    let line = a:base
  endif

  let res = []
  let res2 = []
  let borders = {}

  " Check last occurrence of sequence

  let openbrace  = strridx(line, '{')
  let closebrace = strridx(line, '}')
  let colon      = strridx(line, ':')
  let semicolon  = strridx(line, ';')
  let opencomm   = strridx(line, '/*')
  let closecomm  = strridx(line, '*/')
  let style      = strridx(line, 'style\s*=')
  let atrule     = strridx(line, '@')
  let exclam     = strridx(line, '!')

  if openbrace > -1
    let borders[openbrace] = "openbrace"
  endif
  if closebrace > -1
    let borders[closebrace] = "closebrace"
  endif
  if colon > -1
    let borders[colon] = "colon"
  endif
  if semicolon > -1
    let borders[semicolon] = "semicolon"
  endif
  if opencomm > -1
    let borders[opencomm] = "opencomm"
  endif
  if closecomm > -1
    let borders[closecomm] = "closecomm"
  endif
  if style > -1
    let borders[style] = "style"
  endif
  if atrule > -1
    let borders[atrule] = "atrule"
  endif
  if exclam > -1
    let borders[exclam] = "exclam"
  endif


  if len(borders) == 0 || borders[max(keys(borders))] =~ '^\%(openbrace\|semicolon\|opencomm\|closecomm\|style\)$'
    " Complete properties


    let entered_property = matchstr(line, '.\{-}\zs[a-zA-Z-]*$')

    for m in s:values
      if m =~? '^'.entered_property
        call add(res, m . ':')
      elseif m =~? entered_property
        call add(res2, m . ':')
      endif
    endfor

    return res + res2

  elseif borders[max(keys(borders))] == 'colon'
    " Get name of property
    let prop = tolower(matchstr(line, '\zs[a-zA-Z-]*\ze\s*:[^:]\{-}$'))

    if prop == 'additive-symbols'
      let values = []
    elseif prop == 'align-content'
      let values = ["flex-start", "flex-end", "center", "space-between", "space-around", "stretch"]
    elseif prop == 'align-items'
      let values = ["flex-start", "flex-end", "center", "baseline", "stretch"]
    elseif prop == 'align-self'
      let values = ["auto", "flex-start", "flex-end", "center", "baseline", "stretch"]
    elseif prop == 'animation'
      let values = []
    elseif prop == 'animation-delay'
      let values = []
    elseif prop == 'animation-direction'
      let values = ["normal", "reverse", "alternate", "alternate-reverse"]
    elseif prop == 'animation-duration'
      let values = []
    elseif prop == 'animation-fill-mode'
      let values = ["none", "forwards", "backwards", "both"]
    elseif prop == 'animation-iteration-count'
      let values = []
    elseif prop == 'animation-name'
      let values = []
    elseif prop == 'animation-play-state'
      let values = ["running", "paused"]
    elseif prop == 'animation-timing-function'
      let values = ["cubic-bezier(", "steps(", "linear", "ease", "ease-in", "ease-in-out", "ease-out", "step-start", "step-end"]
    elseif prop == 'background-attachment'
      let values = ["scroll", "fixed"]
    elseif prop == 'background-color'
      let values = ["transparent", "rgb(", "rgba(", "hsl(", "hsla(", "#"]
    elseif prop == 'background-image'
      let values = ["url(", "none"]
    elseif prop == 'background-position'
      let vals = matchstr(line, '.*:\s*\zs.*')
      if vals =~ '^\%([a-zA-Z]\+\)\?$'
        let values = ["top", "center", "bottom"]
      elseif vals =~ '^[a-zA-Z]\+\s\+\%([a-zA-Z]\+\)\?$'
        let values = ["left", "center", "right"]
      else
        return []
      endif
    elseif prop == 'background-repeat'
      let values = ["repeat", "repeat-x", "repeat-y", "no-repeat"]
    elseif prop == 'background-size'
      let values = ["auto", "contain", "cover"]
    elseif prop == 'background'
      let values = ["url(", "scroll", "fixed", "transparent", "rgb(", "#", "none", "top", "center", "bottom" , "left", "right", "repeat", "repeat-x", "repeat-y", "no-repeat", "auto", "contain", "cover"]
    elseif prop == 'border-collapse'
      let values = ["collapse", "separate"]
    elseif prop == 'border-color'
      let values = ["rgb(", "#", "transparent"]
    elseif prop == 'border-spacing'
      return []
    elseif prop == 'border-style'
      let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
    elseif prop =~ 'border-\%(top\|right\|bottom\|left\)$'
      let vals = matchstr(line, '.*:\s*\zs.*')
      if vals =~ '^\%([a-zA-Z0-9.]\+\)\?$'
        let values = ["thin", "thick", "medium"]
      elseif vals =~ '^[a-zA-Z0-9.]\+\s\+\%([a-zA-Z]\+\)\?$'
        let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
      elseif vals =~ '^[a-zA-Z0-9.]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
        let values = ["rgb(", "#", "transparent"]
      else
        return []
      endif
    elseif prop =~ 'border-\%(top\|right\|bottom\|left\)-color'
      let values = ["rgb(", "#", "transparent"]
    elseif prop =~ 'border-\%(top\|right\|bottom\|left\)-style'
      let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
    elseif prop =~ 'border-\%(top\|right\|bottom\|left\)-width'
      let values = ["thin", "thick", "medium"]
    elseif prop == 'border-width'
      let values = ["thin", "thick", "medium"]
    elseif prop == 'border'
      let vals = matchstr(line, '.*:\s*\zs.*')
      if vals =~ '^\%([a-zA-Z0-9.]\+\)\?$'
        let values = ["thin", "thick", "medium"]
      elseif vals =~ '^[a-zA-Z0-9.]\+\s\+\%([a-zA-Z]\+\)\?$'
        let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
      elseif vals =~ '^[a-zA-Z0-9.]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
        let values = ["rgb(", "#", "transparent"]
      else
        return []
      endif
    elseif prop == 'bottom'
      let values = ["auto"]
    elseif prop == 'caption-side'
      let values = ["top", "bottom"]
    elseif prop == 'clear'
      let values = ["none", "left", "right", "both"]
    elseif prop == 'clip'
      let values = ["auto", "rect("]
    elseif prop == 'color'
      let values = ["rgb(", "#"]
    elseif prop == 'content'
      let values = ["normal", "attr(", "open-quote", "close-quote", "no-open-quote", "no-close-quote"]
    elseif prop =~ 'counter-\%(increment\|reset\)$'
      let values = ["none"]
    elseif prop =~ '^\%(cue-after\|cue-before\|cue\)$'
      let values = ["url(", "none"]
    elseif prop == 'cursor'
      let values = ["url(", "auto", "crosshair", "default", "pointer", "move", "e-resize", "ne-resize", "nw-resize", "n-resize", "se-resize", "sw-resize", "s-resize", "w-resize", "text", "wait", "help", "progress"]
    elseif prop == 'direction'
      let values = ["ltr", "rtl"]
    elseif prop == 'display'
      let values = ["inline", "block", "list-item", "run-in", "inline-block", "table", "inline-table", "table-row-group", "table-header-group", "table-footer-group", "table-row", "table-column-group", "table-column", "table-cell", "table-caption", "none"]
    elseif prop == 'elevation'
      let values = ["below", "level", "above", "higher", "lower"]
    elseif prop == 'empty-cells'
      let values = ["show", "hide"]
    elseif prop == 'float'
      let values = ["left", "right", "none"]
    elseif prop == 'font-family'
      let values = ["sans-serif", "serif", "monospace", "cursive", "fantasy"]
    elseif prop == 'font-size'
      let values = ["xx-small", "x-small", "small", "medium", "large", "x-large", "xx-large", "larger", "smaller"]
    elseif prop == 'font-style'
      let values = ["normal", "italic", "oblique"]
    elseif prop == 'font-variant'
      let values = ["normal", "small-caps"]
    elseif prop == 'font-weight'
      let values = ["normal", "bold", "bolder", "lighter", "100", "200", "300", "400", "500", "600", "700", "800", "900"]
    elseif prop == 'font'
      let values = ["normal", "italic", "oblique", "small-caps", "bold", "bolder", "lighter", "100", "200", "300", "400", "500", "600", "700", "800", "900", "xx-small", "x-small", "small", "medium", "large", "x-large", "xx-large", "larger", "smaller", "sans-serif", "serif", "monospace", "cursive", "fantasy", "caption", "icon", "menu", "message-box", "small-caption", "status-bar"]
    elseif prop =~ '^\%(height\|width\)$'
      let values = ["auto"]
    elseif prop =~ '^\%(left\|rigth\)$'
      let values = ["auto"]
    elseif prop == 'letter-spacing'
      let values = ["normal"]
    elseif prop == 'line-height'
      let values = ["normal"]
    elseif prop == 'list-style-image'
      let values = ["url(", "none"]
    elseif prop == 'list-style-position'
      let values = ["inside", "outside"]
    elseif prop == 'list-style-type'
      let values = ["disc", "circle", "square", "decimal", "decimal-leading-zero", "lower-roman", "upper-roman", "lower-latin", "upper-latin", "none"]
    elseif prop == 'list-style'
      return []
    elseif prop == 'margin'
      let values = ["auto"]
    elseif prop =~ 'margin-\%(right\|left\|top\|bottom\)$'
      let values = ["auto"]
    elseif prop == 'max-height'
      let values = ["auto"]
    elseif prop == 'max-width'
      let values = ["none"]
    elseif prop == 'min-height'
      let values = ["none"]
    elseif prop == 'min-width'
      let values = ["none"]
    elseif prop == 'orphans'
      return []
    elseif prop == 'outline-color'
      let values = ["rgb(", "#"]
    elseif prop == 'outline-style'
      let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
    elseif prop == 'outline-width'
      let values = ["thin", "thick", "medium"]
    elseif prop == 'outline'
      let vals = matchstr(line, '.*:\s*\zs.*')
      if vals =~ '^\%([a-zA-Z0-9,()#]\+\)\?$'
        let values = ["rgb(", "#"]
      elseif vals =~ '^[a-zA-Z0-9,()#]\+\s\+\%([a-zA-Z]\+\)\?$'
        let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
      elseif vals =~ '^[a-zA-Z0-9,()#]\+\s\+[a-zA-Z]\+\s\+\%([a-zA-Z(]\+\)\?$'
        let values = ["thin", "thick", "medium"]
      else
        return []
      endif
    elseif prop == 'overflow'
      let values = ["visible", "hidden", "scroll", "auto"]
    elseif prop == 'padding'
      return []
    elseif prop =~ 'padding-\%(top\|right\|bottom\|left\)$'
      return []
    elseif prop =~ 'page-break-\%(after\|before\)$'
      let values = ["auto", "always", "avoid", "left", "right"]
    elseif prop == 'page-break-inside'
      let values = ["auto", "avoid"]
    elseif prop =~ 'pause-\%(after\|before\)$'
      return []
    elseif prop == 'pause'
      return []
    elseif prop == 'pitch-range'
      return []
    elseif prop == 'pitch'
      let values = ["x-low", "low", "medium", "high", "x-high"]
    elseif prop == 'play-during'
      let values = ["url(", "mix", "repeat", "auto", "none"]
    elseif prop == 'position'
      let values = ["static", "relative", "absolute", "fixed"]
    elseif prop == 'quotes'
      let values = ["none"]
    elseif prop == 'richness'
      return []
    elseif prop == 'speak-header'
      let values = ["once", "always"]
    elseif prop == 'speak-numeral'
      let values = ["digits", "continuous"]
    elseif prop == 'speak-punctuation'
      let values = ["code", "none"]
    elseif prop == 'speak'
      let values = ["normal", "none", "spell-out"]
    elseif prop == 'speech-rate'
      let values = ["x-slow", "slow", "medium", "fast", "x-fast", "faster", "slower"]
    elseif prop == 'stress'
      return []
    elseif prop == 'table-layout'
      let values = ["auto", "fixed"]
    elseif prop == 'text-align'
      let values = ["left", "right", "center", "justify"]
    elseif prop == 'text-decoration'
      let values = ["none", "underline", "overline", "line-through", "blink"]
    elseif prop == 'text-indent'
      return []
    elseif prop == 'text-transform'
      let values = ["capitalize", "uppercase", "lowercase", "none"]
    elseif prop == 'top'
      let values = ["auto"]
    elseif prop == 'unicode-bidi'
      let values = ["normal", "embed", "bidi-override"]
    elseif prop == 'vertical-align'
      let values = ["baseline", "sub", "super", "top", "text-top", "middle", "bottom", "text-bottom"]
    elseif prop == 'visibility'
      let values = ["visible", "hidden", "collapse"]
    elseif prop == 'voice-family'
      return []
    elseif prop == 'volume'
      let values = ["silent", "x-soft", "soft", "medium", "loud", "x-loud"]
    elseif prop == 'white-space'
      let values = ["normal", "pre", "nowrap", "pre-wrap", "pre-line"]
    elseif prop == 'widows'
      return []
    elseif prop == 'word-spacing'
      let values = ["normal"]
    elseif prop == 'z-index'
      let values = ["auto"]
    else
      " If no property match it is possible we are outside of {} and
      " trying to complete pseudo-(class|element)
      let element = tolower(matchstr(line, '\zs[a-zA-Z1-6]*\ze:[^:[:space:]]\{-}$'))
      if stridx(',a,abbr,acronym,address,area,b,base,bdo,big,blockquote,body,br,button,caption,cite,code,col,colgroup,dd,del,dfn,div,dl,dt,em,fieldset,form,head,h1,h2,h3,h4,h5,h6,hr,html,i,img,input,ins,kbd,label,legend,li,link,map,meta,noscript,object,ol,optgroup,option,p,param,pre,q,samp,script,select,small,span,strong,style,sub,sup,table,tbody,td,textarea,tfoot,th,thead,title,tr,tt,ul,var,', ','.element.',') > -1
        let values = ["first-child", "link", "visited", "hover", "active", "focus", "lang", "first-line", "first-letter", "before", "after"]
      else
        return []
      endif
    endif

    " Complete values
    let entered_value = matchstr(line, '.\{-}\zs[a-zA-Z0-9#,.(_-]*$')

    for m in values
      if m =~? '^'.entered_value
        call add(res, m)
      elseif m =~? entered_value
        call add(res2, m)
      endif
    endfor

    return res + res2

  elseif borders[max(keys(borders))] == 'closebrace'

    return []

  elseif borders[max(keys(borders))] == 'exclam'

    " Complete values
    let entered_imp = matchstr(line, '.\{-}!\s*\zs[a-zA-Z ]*$')

    let values = ["important"]

    for m in values
      if m =~? '^'.entered_imp
        call add(res, m)
      endif
    endfor

    return res

  elseif borders[max(keys(borders))] == 'atrule'

    let afterat = matchstr(line, '.*@\zs.*')

    if afterat =~ '\s'

      let atrulename = matchstr(line, '.*@\zs[a-zA-Z-]\+\ze')

      if atrulename == 'media'
        let values = ["screen", "tty", "tv", "projection", "handheld", "print", "braille", "aural", "all"]

        let entered_atruleafter = matchstr(line, '.*@media\s\+\zs.*$')

      elseif atrulename == 'import'
        let entered_atruleafter = matchstr(line, '.*@import\s\+\zs.*$')

        if entered_atruleafter =~ "^[\"']"
          let filestart = matchstr(entered_atruleafter, '^.\zs.*')
          let files = split(glob(filestart.'*'), '\n')
          let values = map(copy(files), '"\"".v:val')

        elseif entered_atruleafter =~ "^url("
          let filestart = matchstr(entered_atruleafter, "^url([\"']\\?\\zs.*")
          let files = split(glob(filestart.'*'), '\n')
          let values = map(copy(files), '"url(".v:val')

        else
          let values = ['"', 'url(']

        endif

      else
        return []

      endif

      for m in values
        if m =~? '^'.entered_atruleafter
          call add(res, m)
        elseif m =~? entered_atruleafter
          call add(res2, m)
        endif
      endfor

      return res + res2

    endif

    let values = ["charset", "page", "media", "import", "font-face"]

    let entered_atrule = matchstr(line, '.*@\zs[a-zA-Z-]*$')

    for m in values
      if m =~? '^'.entered_atrule
        call add(res, m .' ')
      elseif m =~? entered_atrule
        call add(res2, m .' ')
      endif
    endfor

    return res + res2

  endif

  return []

endfunction
