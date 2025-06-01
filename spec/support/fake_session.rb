class FakeSession < Hash
#セッションぽくするために必要な機能を追加したハッシュ
  def enabled?; true; end
  def destroy; nil; end
  def loaded?; true; end
end
  