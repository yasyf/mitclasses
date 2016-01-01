@FeedbackList = React.createClass
  render: ->
    feedbacks = (<Feedback handlers={@props.handlers} {...feedback}/> for feedback in @props.feedbacks)
    <div className='FeedbackList'>
      {feedbacks}
    </div>
