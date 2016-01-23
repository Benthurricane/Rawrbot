require 'plugins/Karma'

def delete_key_from_db(db, key)
  db.execute('DELETE FROM karma WHERE key=?', key)
  expect(db.get_first_value('SELECT val FROM karma WHERE key=?', key)).to eq nil
end

RSpec.describe 'Karma#display' do
  before(:each) do
    @bot = make_bot()
    @bot.loggers.level = :error
    @bot.plugins.register_plugin(Karma)
  end

  context 'key does not exist in the database' do
    let(:key) { 'imatestvalue' }
    let(:db) { 'karma.sqlite3' }

    before(:each) do
      # TODO: refactor Karma plugin so we can use a test-only db here
      delete_key_from_db(SQLite3::Database.new(db), key)
    end

    it 'replies once' do
      msg = make_message(@bot, "!karma #{key}", channel: '#testchan')
      expect(get_replies(msg).length).to eq 1
    end
    it 'shows karma as neutral' do
      msg = make_message(@bot, "!karma #{key}", channel: '#testchan')
      expect(get_replies(msg)[0].text).to eq "#{key} has neutral karma."
    end
  end
end
