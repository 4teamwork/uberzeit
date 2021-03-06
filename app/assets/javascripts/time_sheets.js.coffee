document.originalTitle = document.title

$(document).on 'ajax:error', '.reveal-modal form', (xhr, status, error) ->
  console.log xhr, status, error

$(document).on 'ajax:complete', '.reveal-modal form', (xhr, status) ->
  $(this).foundation('reveal', 'close')

$(document).on 'ajax:complete', '.stop-timer', (xhr, status) ->
  window.location.reload()

$(document).on 'click', '.stop-timer', ->
  unless $('.stop-timer').hasClass 'disabled'
    $('.stop-timer i').removeClass('fa-spin')

$(document).on 'click', '.unhider', ->
  $('.' + $(this).data('hide-class')).hide()
  $('.' + $(this).data('unhide-class')).show()
  false

$(document).on 'keyup change', '#time_entry_end_time, #time_entry_start_time', ->

  startEl = $("#time_entry_start_time")
  endEl   = $("#time_entry_end_time")

  if endEl.val()
    $("#time_entry_submit").val(I18n.t('time_entries.form.save'))
  else
    $("#time_entry_submit").val(I18n.t('time_entries.form.start_timer'))

  startValue = $.fn.timepicker.parseTime startEl.val()
  endValue   = $.fn.timepicker.parseTime endEl.val()

  if startValue and endValue
    start = startEl.timepicker().format(startValue)
    end   = endEl.timepicker().format(endValue)

    value = timeDiff(start, end, undefined, undefined, false)
  else
    value = ""

  $(".time-difference").html(value)

# global functions
window.formatDuration = (duration_in_seconds) ->
  duration = moment.duration(duration_in_seconds, 'seconds')
  hours = Math.floor(duration.asHours())
  minutes = duration.minutes()
  prefix = ""

  if hours < 0
    hours = hours * -1
    prefix = "−"

  if minutes < 0
    minutes = minutes * -1
    prefix = "−"

  if hours < 10
    hours = "0#{hours}"

  if minutes < 10
    minutes = "0#{minutes}"

  "#{prefix}#{hours}:#{minutes}"

window.timeDiff = (start_time, end_time, start_date, end_date, countdown = true) ->
  if typeof start_date == 'undefined'
    start_date = moment().format('YYYY-MM-DD')

  if typeof end_date == 'undefined'
    end_date = moment().format('YYYY-MM-DD')

  start = moment("#{start_date} #{start_time}")
  end   = moment("#{end_date} #{end_time}")

  if start >= end && countdown == false
    end.add('days', 1)

  delta = end.diff(start, 'seconds')

  formatDuration delta

$ ->
  # Do not put event listeners inside here (they will add up through turbolinks)

  updateTimes = ->
    if $('.ajax.summary_for_date').length
      $.getJSON $('.ajax.summary_for_date').attr('href'), (data) ->
        # title bar
        if window.timerStarted
          document.title = '[' + data.total + '] ' + document.originalTitle

        $('.time.total.active').text data.total
        $('.time.bonus').text data.bonus
        $('.time.week-total').text data.week_total

        $('.timer-current').text data.timer_duration_for_day
        if data.timer_duration_for_day != data.timer_duration_since_start
          $('.timer-overall').text data.timer_duration_since_start
          $('.timer-overall-label').removeClass('hidden')

        # disable stop timer link if there is no timer duration (e.g. timer in future)
        if $('.timer-current').text() == "00:00"
          $('.stop-timer').addClass 'disabled'
          $('.stop-timer').bind 'click', (e) ->
            e.preventDefault()
            false
        else
          $('.stop-timer').removeClass 'disabled'
          $('.stop-timer').unbind 'click'

  # on page load
  updateTimes()
  if $('.timer-current').length > 0 && window.timerStarted != true
    window.timerStarted = true
    setTimeout((->
      updateTimes()
      setTimeout arguments.callee, 30000
      ), 0)


  $('.jump-date').pickadate
    format: 'yyyy-mm-dd'

  $('.jump-date').on 'change', (event) ->
    el = $(@)
    console.log el.val(), el.data('current-day')
    if el.val().length > 0 && el.val() != el.data('current-day')
      window.location.href = el.data('jump-url') + el.val()

  $('.jump-date-starter').on 'click', (event) ->
    $('.jump-date').data('pickadate').open()
    event.stopPropagation()
