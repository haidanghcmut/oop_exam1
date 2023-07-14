require "csv"

class User
    attr_accessor :owner, :balance, :card_number, :password
    def initialize(owner, balance, card_number, password)
        @owner = owner
        @card_number = card_number
        @password = password
        @balance = balance
    end

    def to_hash
        {
            owner: @owner,
            balance: @balance,
            card_number: @card_number,
            password: @password
        }
    end
end


class ATM
    def initialize
       @accounts = load_accounts_from_csv
       @current_account = nil
    end
     
    def start
        puts '=== ATM ==='
        login
        show_menu
        process_menu_choice until @current_account.nil?
        puts 'Thank you for using the ATM. Goodbye!'
    end

    def login
        puts 'Please enter your card number:'
        card_number_enter = gets.chomp
        puts 'Please enter your password:'
        password_enter = gets.chomp
        @current_account = @accounts.find { |accountt| accountt[:card_number] == card_number_enter.to_i || accountt[:password]== password_enter.to_i }
        if @current_account.nil?
            puts 'Invalid card number or password. Please try again.'
            login
        elsif(@current_account[:card_number] == card_number_enter.to_i && @current_account[:password] == password_enter.to_i)
            puts "Welcome, #{@current_account.owner}!"
            puts "Your balance: $#{@current_account.balance}"
        end
    end

    def show_menu
        puts '=== Menu ==='
        puts '1. Withdraw'
        puts '2. Check Balance'
        puts '3. Deposit'
        puts '4. Transfer'
        puts '5. Transfer to another account'
        puts '6. Exit'
    end

    def process_menu_choice
        choice = gets.chomp.to_i
        case choice
        when 1
            withdraw
        when 2
            check_balance
        when 3
            deposit
        when 4
            transfer
        when 5
            transfer_to_another_account
        when 6
            @current_account = nil
        else
            puts 'Invalid choice. Please try again.'
        end
    end

    def withdraw
        puts 'How much would you like to withdraw?'
        amount = gets.chomp.to_i
        if amount > @current_account.balance
            puts 'Insufficient funds.'
        else
            @current_account.balance -= amount
            save_accounts_to_csv
            puts "Your new balance is $#{@current_account.balance}"
        end
    end

    def check_balance
        puts "Your balance is $#{@current_account.balance}"
    end

    def deposit
        puts 'How much would you like to deposit?'
        amount = gets.chomp.to_i
        @current_account.balance += amount
        save_accounts_to_csv
        puts "Your new balance is $#{@current_account.balance}"
    end

    def transfer
      puts 'Enter the account number to transfer to:'
        account_number = gets.chomp
       puts 'Enter the card number to transfer to:'
        recipient_account = @accounts.find { |account| account.card_number == account_number.to_s }
        if recipient_account.nil?
            puts 'Invalid account number.'
            return
        end
    end
    

    def transfer_to_another_account
    puts 'Enter the account number to transfer to:'
    account_number = gets.chomp
    recipient_account = @accounts.find { |account| account.card_number == account_number }
    if recipient_account.nil?
      puts 'Invalid account number.'
      return 
    end
    end

    def log_out
        @current_account = nil
    end
    # load file CSV
    def load_accounts_from_csv
        accountt = []
        if (File.file?('./accounts.csv') && !File.zero?('./accounts.csv'))
            CSV.foreach('./accounts.csv', headers: true) do |row|
                owner = row['owner']
                balance = row['balance'].to_i
                card_number = row['card_number'].to_i
                password = row['password'].to_i

                account = { owner: owner, balance: balance, card_number: card_number, password: password }
                accountt << account
            end
            return accountt
        else 
            File.new("./accounts.csv", 'w')   
        end
    end

    def save_accounts_to_csv
        CSV.open('accounts.csv', 'w') do |csv|
          @accounts.each do |account|
            csv << [account.owner, account.balance, account.card_number, account.password]
          end
    end
   end
end


atm = ATM.new
atm.start