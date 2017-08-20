class Boleite::InputReceiver
  abstract class Glue
    abstract def interested?(input) : Bool
    abstract def execute(input) : Nil
  end

  class GlueImp(A, P) < Glue
    def initialize(@action : A, @callback : P)
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

  def process(event : InputEvent)
    @actions.each do |glue|
      glue.execute(event) if glue.interested?(event)
    end
  end
end
