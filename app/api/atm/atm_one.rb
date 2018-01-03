require_relative '../../logic/atm'
module ATMOne
  class Data < Grape::API
    resource :load do
      desc 'Load notes to ATM'
      params do
        requires :stack, type: Hash, desc: 'Package to load into ATM'
      end
      post do
        status 200
        ATM.new.load(params[:stack])
      end
    end

    resource :withdraw do
      desc 'Withdraw notes from ATM'
      params do
        requires :amount, type: Integer, desc: 'Withdrawal amount'
      end
      post do
        status 200
        ATM.new.withdraw(params[:amount])
      end
    end

    resource :check do
      desc 'Check remaining notes, starts ATM if already not'
      get do
        ATM.new.stack
      end
    end
  end
end
