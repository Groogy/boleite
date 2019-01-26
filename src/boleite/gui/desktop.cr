class Boleite::GUI
  abstract class Root < Container
  end

  class Desktop < Root
    def initialize
      super
    end

    def reset_acc_allocation
      @acc_allocation = @allocation
    end

    def update_acc_allocation
      @acc_allocation = @acc_allocation.merge @allocation
      @acc_allocation = @acc_allocation.expand 2.0
    end
  end
end
