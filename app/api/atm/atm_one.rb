require_relative 'atm'
module ATMOne
  class Data < Grape::API
    resource :load do
      desc 'Load notes to ATM'
      params do
        requires :stack, type: Hash, desc: 'Package to load into ATM'
      end
      post do
        status 200
        @@atm ||= ATM.new 
        @@atm.load(params[:stack].to_hash)
      end
    end

    resource :withdraw do
      desc 'Withdraw notes from ATM'
      params do
        requires :amount, type: Integer, desc: 'Withdrawal amount'
      end
      post do
        status 200
        @@atm ||= ATM.new
        @@atm.withdraw(params[:amount])
      end
    end

    resource :check do
      desc 'Check remaining notes, starts ATM if already not'
      get do
        @@atm ||= ATM.new
        @@atm.stack
      end
    end
  end
end
