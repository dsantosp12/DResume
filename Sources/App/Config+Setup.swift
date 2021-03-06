import FluentProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
      self.preparations.append(User.self)
      self.preparations.append(Skill.self)
      self.preparations.append(Language.self)
      self.preparations.append(Education.self)
      self.preparations.append(Attachment.self)
      self.preparations.append(Portfolio.self)
      self.preparations.append(Link.self)
      self.preparations.append(Section.self)
      self.preparations.append(SectionItem.self)
    }
}
