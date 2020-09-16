require 'rails_helper'

RSpec.describe OrderAddress, type: :model do
  describe 'orders#create' do
    before do
      user = FactoryBot.create(:user)
      item = FactoryBot.build(:item, user_id: user.id)
      item.image = fixture_file_upload('public/images/test_image.png')
      item.save
      @order_address = FactoryBot.build(:order_address, item_id: item.id, user_id: user.id )
    end

    describe '購入' do
      context '購入がうまくいくとき' do
        it "郵便番号、都道府県、市区町村、電話番号が正しく入力されている時" do
          expect(@order_address).to be_valid
        end

        it "建物名が未入力でも購入できる" do
          @order_address.building = ""
          expect(@order_address).to be_valid
        end

        it "出品者と購入者が別人だと購入できる。" do
          another = FactoryBot.create(:user)
          if @order_address.user_id != another
            expect(@order_address).to be_valid
          end
        end
      end

      context '購入がうまくいかない時' do
        it "tokenがなければ購入できない。" do
          @order_address.token = ""
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Token can't be blank")
        end

        it "郵便番号がなければ購入できない。" do
          @order_address.postal_code = ""
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Postal code can't be blank")
        end

        it "郵便番号が半角数字###-####で登録しないと購入できない。" do
          @order_address.postal_code = "kkk-kkkk"
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Postal code input correctly")
        end

        it "郵便番号が半角数字且つ「-」ハイフンがなければ購入できない。" do
          @order_address.postal_code = "6561334"
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Postal code input correctly")
        end

        it "都道府県が選択されてなかったら購入できない。" do
          @order_address.prefecture_id = ""
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Prefecture Select")
        end

        it "市町村が記入漏れだったら購入できない。" do
          @order_address.city = ""
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("City can't be blank")
        end

        it "番地が記入漏れだったら購入できない。" do
          @order_address.number = ""
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Number can't be blank")
        end

        it "電話番号が未入力だったら購入できない。" do
          @order_address.phone = ""
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Phone can't be blank")
        end
        
        it "電話番号が0から始まる数字でなければ購入できない。" do
          @order_address.phone = "99999999999"
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Phone number input correctly")
        end

        it "電話番号に「-」があれば購入できない。" do
          @order_address.phone = "080-0808-0808"
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Phone number input correctly")
        end

        it "電話番号は11桁以下でなければ購入できない。" do
          @order_address.phone = "0808888888888"
          @order_address.valid?
          expect(@order_address.errors.full_messages).to include ("Phone number too longth")
        end
      end
    end
  end
end
