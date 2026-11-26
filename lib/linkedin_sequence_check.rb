# frozen_string_literal: true

require 'json'

# Checks a LinkedIn outreach sequence (five branches) against the rules of the OneGTMLab LinkedIn outreach playbook.
module LinkedinSequenceCheck
  BRANCHES = %w[connection_note on_acceptance existing_connection inmail generic_fallback].freeze
  MAX_WORDS = 70 # "messages stay under about 70 words"
  POST_LABELS = %w[original quote reshare].freeze

  Issue = Struct.new(:branch, :message)

  def self.words(text)
    text.to_s.split(/\s+/).reject(&:empty?).size
  end

  # seq: { "sender" => "Name", "connection_note" => "...", ... , "hook" => { "text" => "...", "label" => "original" } }
  def self.check(seq, note_limit: nil)
    issues = []
    BRANCHES.each do |b|
      issues << Issue.new(b, 'branch is missing or empty') if seq[b].to_s.strip.empty?
    end
    BRANCHES.each do |b|
      t = seq[b].to_s
      next if t.strip.empty?
      issues << Issue.new(b, "#{words(t)} words, over the #{MAX_WORDS} word guide") if words(t) > MAX_WORDS
      issues << Issue.new(b, 'contains a stray brace or unresolved variable') if t =~ /[{}]|%\w+%|\[\[|\]\]/
      issues << Issue.new(b, 'contains an em dash') if t.include?("—")
    end
    note = seq['connection_note'].to_s
    issues << Issue.new('connection_note', 'connection note must not contain a link') if note =~ %r{https?://|www\.}i
    if note_limit && note.length > note_limit
      issues << Issue.new('connection_note', "#{note.length} characters, over your limit of #{note_limit}")
    end
    ex = seq['existing_connection'].to_s
    if ex =~ /\b(thanks for connecting|great to be connected|since we(?:'re| are) connected|we(?:'re| are) connected)\b/i
      issues << Issue.new('existing_connection', 'opens by remarking on the connection; open with substance')
    end
    sender = seq['sender'].to_s.strip
    issues << Issue.new('sender', 'sender name is missing') if sender.empty?
    unless sender.empty?
      BRANCHES.each do |b|
        t = seq[b].to_s
        next if t.strip.empty?
        # "do not introduce the sender by name"
        issues << Issue.new(b, 'introduces the sender by name') if t =~ /\b(?:i am|i'm|my name is)\s+#{Regexp.escape(sender.split.first)}\b/i
      end
    end
    hook = seq['hook']
    if hook && !hook['text'].to_s.strip.empty?
      label = hook['label'].to_s
      issues << Issue.new('hook', "post label must be one of #{POST_LABELS.join(', ')}") unless POST_LABELS.include?(label)
      issues << Issue.new('hook', "a #{label} is not something the person wrote; use the generic opener") if %w[quote reshare].include?(label)
    end
    issues
  end
end
