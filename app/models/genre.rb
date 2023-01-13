class Genre < ActiveHash::Base
  self.data = [
    {id: 1, name: '肉料理'}, {id: 2, name: '魚料理'}, {id: 3, name: '野菜料理'}, {id: 4, name: 'その他'}
  ]
end