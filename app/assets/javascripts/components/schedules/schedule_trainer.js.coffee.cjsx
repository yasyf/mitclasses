@ScheduleTrainer = React.createClass
  getInitialState: ->
    recommendations: [], offset: 0, done: false
  fetchRecommendations: (count = 10) ->
    $.get @props.endpoints.recommendations,
      offset: @state.offset
      count: count
    .then (response) =>
      @setState
        recommendations: response.recommendations
        offset: @state.offset + count
        done: response.recommendations.length is 0
  createFeedback: (recommendation, positive) ->
    $.post @props.endpoints.feedbacks,
      feedback:
        recommendation_id: recommendation.id
        positive: positive
  nextRecommendation: (positive) ->
    @createFeedback @state.recommendations[0], positive
    .then =>
      needsUpdate = @state.recommendations.length is 0
      @setState recommendations: _.drop @state.recommendations
      @fetchRecommendations() if needsUpdate
  componentDidMount: ->
    @fetchRecommendations()
  render: ->
    <div className='scheduleTrainer'>
      <h1>Schedule Training</h1>
      <ScheduleRecommendation data={@state.recommendations[0]} callback={@nextRecommendation} done={@state.done}/>
    </div>
