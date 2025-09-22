class AlbumPolicy < ApplicationPolicy
  def index?
      true
  end

  def show?
      true
  end

  def create?
    user.artist?
  end

  def update?
    user.super_admin? ||  user.artist? && record.artist.user == user
  end

  def destroy?
    user.super_admin? ||  user.artist? && record.artist.user == user
  end
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
