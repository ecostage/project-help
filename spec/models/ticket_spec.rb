require 'spec_helper'

describe Ticket do
  let(:ticket) { FactoryGirl.create(:ticket) }
  let!(:group) { create(:group, members: [client, client2]) }
  let(:attendant) { create(:attendant) }
  let(:client) { create(:client) }
  let(:client2) { create(:client) }
  let(:alone_client) { create(:client) }

  describe 'associations' do
    it { should have_many(:comments) }
    it { should belong_to(:channel) }
  end

  it 'should humanize status' do
    expect(ticket.status_humanized).to eq(I18n.translate("ticket.statuses.#{ticket.status}"))
  end

  describe '#user_scope' do
    let(:client_ticket) { create(:ticket, created_by: client) }
    let(:client2_ticket) { create(:ticket, created_by: client2) }
    let(:alone_client_ticket) { create(:ticket, created_by: alone_client) }

    it 'should scope by user permission' do
      attendant_tickets = [alone_client_ticket, client_ticket]

      expect(Ticket.user_scope(alone_client)).to contain_exactly(alone_client_ticket)
      expect(Ticket.user_scope(attendant)).to contain_exactly(*attendant_tickets)
    end

    it 'should scope by user group' do
      tickets = [client_ticket, client2_ticket]
      expect(Ticket.user_scope(client)).to contain_exactly(*tickets)
    end
  end

  describe '#old?' do
    context 'ticket older than 15 days' do
      subject {
        create(:ticket, updated_at: 16.days.ago)
      }

      it { expect(subject.old?).to be_truthy }
    end

    context 'ticket newer than 15 days' do
      subject {
        create(:ticket, updated_at: 10.days.ago)
      }

      it { expect(subject.old?).to be_falsy }
    end
  end

  describe '#after_find' do
    it 'sends auto_approve!', :vcr do
      create(:ticket, updated_at: 16.days.ago, status: :done)
      ticket = Ticket.last
      expect(ticket.status).to eq('approved')
    end
  end
end
