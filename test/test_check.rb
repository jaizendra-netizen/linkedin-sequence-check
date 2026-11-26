# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/linkedin_sequence_check'

class CheckTest < Minitest::Test
  def base
    JSON.parse(File.read(File.join(__dir__, '..', 'examples', 'sequence.json')))
  end

  def msgs(seq, **o)
    LinkedinSequenceCheck.check(seq, **o).map(&:message)
  end

  def test_example_is_clean
    assert_empty msgs(base)
  end

  def test_missing_branch
    s = base
    s.delete('inmail')
    assert_includes msgs(s), 'branch is missing or empty'
  end

  def test_too_long_and_braces_and_link
    s = base
    s['on_acceptance'] = (['word'] * 71).join(' ')
    s['connection_note'] = 'Hi {first_name}, see https://example.test'
    m = msgs(s)
    assert(m.any? { |x| x.include?('71 words') })
    assert_includes m, 'contains a stray brace or unresolved variable'
    assert_includes m, 'connection note must not contain a link'
  end

  def test_note_limit_only_when_given
    s = base
    s['connection_note'] = 'a' * 50
    assert_empty msgs(s)
    assert(msgs(s, note_limit: 40).any? { |x| x.include?('over your limit of 40') })
  end

  def test_existing_connection_opener
    s = base
    s['existing_connection'] = 'Thanks for connecting! Quick idea for you.'
    assert(msgs(s).any? { |x| x.include?('remarking on the connection') })
  end

  def test_sender_intro_and_hook_labels
    s = base
    s['generic_fallback'] = "I'm Sample, and we help teams."
    s['hook']['label'] = 'reshare'
    m = msgs(s)
    assert_includes m, 'introduces the sender by name'
    assert(m.any? { |x| x.include?('not something the person wrote') })
  end
end
