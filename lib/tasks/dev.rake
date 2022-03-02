# frozen_string_literal: true
require 'faker'
I18n.reload!

namespace :dev do
  DEFAULT_PASSWORD = 123_456
  DEFAULT_FILES_PATH = File.join(Rails.root, 'lib', 'tmp')

  desc 'Configurando o ambiente'
  task setup: :environment do
    if Rails.env.development?
      show_spinner('Apagando BD...') { `rails db:drop` }
      show_spinner('Criando BD...') { `rails db:create` }
      show_spinner('Migrando BD...') { `rails db:migrate` }
      show_spinner('Cadastrando Adm Padrão...') { `rails dev:add_default_admin` }
      show_spinner('Cadastrando Adm Extras...') { `rails dev:add_extras_admin` }
      show_spinner('Cadastrando User Padrão...') { `rails dev:add_default_user` }
      show_spinner('Cadastrando assuntos padrões...') { `rails dev:add_subjects` }
      show_spinner('Cadastrando questões e respostas...') { `rails dev:add_answers_and_questions` }
    else
      puts 'Você não está em ambiente de desenvolvimento!'
    end
  end

  desc 'Adiciona o administrador padrão'
  task add_default_admin: :environment do
    Admin.create!(
      email: 'admin@admin.com',
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc 'Adiciona o administrador teste'
  task add_extras_admin: :environment do
    10.times do
      Admin.create!(
        email: Faker::Internet.email,
        password: DEFAULT_PASSWORD,
        password_confirmation: DEFAULT_PASSWORD
      )
    end
  end

  desc 'Adiciona o usuário padrão'
  task add_default_user: :environment do
    User.create!(
      email: 'user@user.com',
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc 'Adiciona assuntos padrões'
  task add_subjects: :environment do
    file_name = 'subjects.txt'
    file_path = File.join(DEFAULT_FILES_PATH, file_name)

    File.open(file_path, 'r').each do |line|
      Subject.create!(description: line.strip)
    end
  end

  desc 'Adiciona perguntas e respostas'
  task add_answers_and_questions: :environment do
    Subject.all.each do |subject|
      rand(5..10).times do |i|
        params = create_question_params(subject)
        answers_array = params[:question][:answers_attributes]

        add_answer(answers_array)
        select_true_answer(answers_array)

        Question.create!(params[:question])
      end
    end
  end

  private

  def create_question_params(subject = Subject.all.sample)
    { question: {
        description: Faker::Lorem.paragraph,
        subject: subject,
        answers_attributes: {}
    }}
  end

  def create_answer_params(correct = false)
    { description: Faker::Lorem.sentence, correct: correct }
  end

  def add_answer(answers_array = [])
    rand(2..5).times do |j|
      answers_array.push(
        create_answer_params
      )
    end
  end

  def select_true_answer(answers_array = [])
    select_index = rand(answers_array.size)
    answers_array[select_index] = create_answer_params(true)
  end

  def show_spinner(msg_start)
    spinner = TTY::Spinner.new("[:spinner] #{msg_start}")
    spinner.auto_spin
    yield
    spinner.success('(Concluido com sucesso !)')
  end
end
