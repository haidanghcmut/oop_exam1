require 'csv'

class Account
  attr_accessor :card_number, :password, :balance, :owner_name

  def initialize(card_number, password, balance, owner_name)
    @card_number = card_number
    @password = password
    @balance = balance
    @owner_name = owner_name
  end
end

class AMT
  def initialize
    @accounts = load_accounts_data
  end

  def start
    puts "Vui long dang nhap so the:"
    card_number = gets.chomp.to_i
    puts "Password:"
    password = gets.chomp.to_i

    if login(card_number, password)
      puts "Dang nhap thanh cong!"
      display_menu
    else
      puts "Dang nhap that bai! Vui long thu lai."
    end
  end

  private

  def load_accounts_data
    accounts = []

    CSV.foreach('accounts.csv', headers: true) do |row|
      card_number = row['CardNumber'].to_i
      password = row['Password'].to_i
      balance = row['Balance'].to_i
      owner_name = row['OwnerName']

      account = Account.new(card_number, password, balance, owner_name)
      accounts << account
    end

    accounts
  end

  def login(card_number, password)
    account = @accounts.find { |acc| acc.card_number == card_number && acc.password == password }
    return false if account.nil?

    @current_account = account
    true
  end

  def display_menu
    loop do
      puts "\nMenu:"
      puts "[1] Rut tien"
      puts "[2] Kiem tra so du"
      puts "[3] Nap tien vao tai khoan"
      puts "[4] Chuyen khoan sang tai khoan khac"
      puts "[5] Thoat"

      choice = gets.chomp.to_i

      case choice
      when 1
        withdraw_money
      when 2
        check_balance
      when 3
        deposit_money
      when 4
        transfer_money
      when 5
        puts "Cam on ban da su dung dich vu!"
        break
      else
        puts "Lua chon khong hop le! Vui long thu lai."
      end
    end
  end

  def withdraw_money
    puts "Nhap so tien can rut:"
    amount = gets.chomp.to_i

    if amount <= 0
      puts "So tien rut phai lon hon 0!"
    elsif amount > @current_account.balance
      puts "So du trong tai khoan khong du!"
    else
      @current_account.balance -= amount
      update_accounts_data
      puts "Rut tien thanh cong! So du con lai: #{@current_account.balance}"
    end
  end

  def check_balance
    puts "So du trong tai khoan: #{@current_account.balance}"
  end

  def deposit_money
    puts "Nhap so tien can nap:"
    amount = gets.chomp.to_i

    if amount <= 0
      puts "So tien nap phai lon hon 0!"
    else
      @current_account.balance += amount
      update_accounts_data
      puts "Nap tien thanh cong! So du hien tai: #{@current_account.balance}"
    end
  end

  def transfer_money
    puts "Nhap so tai khoan can chuyen tien:"
    target_card_number = gets.chomp.to_i

    puts "Nhap so tien can chuyen:"
    amount = gets.chomp.to_i

    if amount <= 0
      puts "So tien chuyen phai lon hon 0!"
    elsif amount > @current_account.balance
      puts "So du trong tai khoan khong du!"
    else
      target_account = @accounts.find { |acc| acc.card_number == target_card_number }

      if target_account.nil?
        puts "Khong tim thay tai khoan nhan!"
      else
        @current_account.balance -= amount
        target_account.balance += amount
        update_accounts_data
        puts "Chuyen tien thanh cong!"
      end
    end
  end

  def update_accounts_data
    CSV.open('accounts.csv', 'w') do |csv|
      csv << ['CardNumber', 'Password', 'Balance', 'OwnerName']

      @accounts.each do |account|
        csv << [account.card_number, account.password, account.balance, account.owner_name]
      end
    end
  end
end

amt = AMT.new
amt.start
