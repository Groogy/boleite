class Boleite::InputReceiver
  abstract class Glue
    abstract def interested?(input) : Bool
    abstract def execute(input) : Nil
    abstract def for?(type) : Bool
  end

  class GlueImp(A, P) < Glue
    def initialize(@action : A, @callback : P)
    end

    def for?(type)
      A == type
    end

    def interested?(input) : Bool
      @action.interested? input
    end

    def execute(input) : Nil
      args = @action.translate input
      @callback.call *args
    end
  end

  @actions = [] of Glue

  def register(action_type, proc)
    @actions << GlueImp.new(action_type.new, proc)
  end

  def register_instance(action, proc)
    @actions << GlueImp.new action, proc
  end

  def unregister(action_type)
    @actions.select! do |action|
      action.for? action_Type
    end
  end

  def clear
    @actions.clear
  end

  def process(event : InputEvent)
    @actions.each do |glue|
      glue.execute(event) if glue.interested?(event)
    end
  end
end
