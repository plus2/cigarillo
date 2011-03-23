Object.prototype.tapp = (tag) ->
  if tag
    console.log "#{tag}=",@
  else
    console.log @
  @

jQuery ($) ->
  $('.toggle-raw').click ->
    $(this).parents('td').find('.raw').toggleClass('hidden')
    false

  return
  $('nav > ul > li').tapp().mouseenter ->
    @.tapp("over")
    $(@).addClass('active')
        .find('a:first').addClass('active')
        .end()
        .one 'mouseleave', ->
          $(@).removeClass('active')
              .find('a:first').removeClass('active')
