$ ->
  $('body').on 'click', 'a[data-confirm]', (ev)->
    ev.preventDefault()
    confirmMessage = $(this).data('confirm') || 'Are you'?

    if (window.confirm(confirmMessage))
      window.location.href = $(this).attr('href')
