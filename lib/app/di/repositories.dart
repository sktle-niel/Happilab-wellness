import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/fake_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/community/data/community_api.dart';
import '../../features/community/data/fake_community_repository.dart';
import '../../features/community/domain/community_repository.dart';
import '../../features/notifications/data/fake_notifications_repository.dart';
import '../../features/notifications/data/notifications_api.dart';
import '../../features/notifications/domain/notifications_repository.dart';
import '../../features/profile/data/fake_profile_repository.dart';
import '../../features/profile/data/profile_api.dart';
import '../../features/profile/domain/profile_repository.dart';
import '../../features/referrals/data/fake_referrals_repository.dart';
import '../../features/referrals/data/referrals_api.dart';
import '../../features/referrals/domain/referrals_repository.dart';
import '../../features/rewards/data/fake_rewards_repository.dart';
import '../../features/rewards/data/rewards_api.dart';
import '../../features/rewards/domain/rewards_repository.dart';
import '../../features/support/data/fake_support_desk.dart';
import '../../features/support/data/fake_support_repository.dart';
import '../../features/support/data/support_api.dart';
import '../../features/support/data/support_desk_api.dart';
import '../../features/support/domain/support_desk.dart';
import '../../features/support/domain/support_repository.dart';
import '../../shared/data/catalogue_api.dart';
import '../../shared/data/delivery_address_api.dart';
import '../../shared/data/fake_catalogue_repository.dart';
import '../../shared/data/fake_delivery_address_repository.dart';
import '../../shared/data/fake_member_repository.dart';
import '../../shared/data/fake_orders_repository.dart';
import '../../shared/data/fake_payout_accounts_repository.dart';
import '../../shared/data/member_api.dart';
import '../../shared/data/orders_api.dart';
import '../../shared/data/payout_accounts_api.dart';
import '../../shared/domain/catalogue_repository.dart';
import '../../shared/domain/delivery_address.dart';
import '../../shared/domain/member_repository.dart';
import '../../shared/domain/orders.dart';
import '../../shared/domain/payout_account.dart';

/// Every data source the app reads, behind its contract.
///
/// Bound once, here, by [BackendMode]: the API implementations over the one
/// [ApiClient], or the fakes that serve the bundled placeholders. Screens and
/// stores hold the contracts and never learn which they were given.
class Repositories {
  const Repositories({
    required this.auth,
    required this.member,
    required this.catalogue,
    required this.payoutAccounts,
    required this.deliveryAddress,
    required this.orders,
    required this.notifications,
    required this.referrals,
    required this.rewards,
    required this.community,
    required this.profile,
    required this.support,
    required this.supportDesk,
  });

  factory Repositories.forConfig(AppConfig config, ApiClient client) =>
      config.usesApi ? Repositories.api(client) : Repositories.fake();

  factory Repositories.api(ApiClient client) => Repositories(
    auth: AuthApi(client),
    member: MemberApi(client),
    catalogue: CatalogueApi(client),
    payoutAccounts: PayoutAccountsApi(client),
    deliveryAddress: DeliveryAddressApi(client),
    orders: OrdersApi(client),
    notifications: NotificationsApi(client),
    referrals: ReferralsApi(client),
    rewards: RewardsApi(client),
    community: CommunityApi(client),
    profile: ProfileApi(client),
    support: SupportApi(client),
    supportDesk: SupportDeskApi(client),
  );

  /// The bundled placeholders. [payoutAccounts] and [deliveryAddress] may be
  /// seeded, for a test that starts with them already saved.
  factory Repositories.fake({
    Iterable<PayoutAccount> payoutAccounts = const [],
    DeliveryAddress? deliveryAddress,
  }) => Repositories(
    auth: const FakeAuthRepository(),
    member: const FakeMemberRepository(),
    catalogue: const FakeCatalogueRepository(),
    payoutAccounts: FakePayoutAccountsRepository(initial: payoutAccounts),
    deliveryAddress: FakeDeliveryAddressRepository(initial: deliveryAddress),
    orders: FakeOrdersRepository(),
    notifications: FakeNotificationsRepository(),
    referrals: const FakeReferralsRepository(),
    rewards: const FakeRewardsRepository(),
    community: FakeCommunityRepository(),
    profile: const FakeProfileRepository(),
    support: const FakeSupportRepository(),
    supportDesk: FakeSupportDesk(),
  );

  final AuthRepository auth;
  final MemberRepository member;
  final CatalogueRepository catalogue;
  final PayoutAccountsRepository payoutAccounts;
  final DeliveryAddressRepository deliveryAddress;
  final OrdersRepository orders;
  final NotificationsRepository notifications;
  final ReferralsRepository referrals;
  final RewardsRepository rewards;
  final CommunityRepository community;
  final ProfileRepository profile;
  final SupportRepository support;
  final SupportDesk supportDesk;
}
