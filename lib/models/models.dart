// ─── Contractor Model ───────────────────────────────────────────────
class Contractor {
  final String id;
  String name;
  String email;
  String contactName;
  String remarks;
  bool isActive;
  DateTime? contractStartDate;
  DateTime? contractEndDate;

  Contractor({
    required this.id,
    required this.name,
    required this.email,
    this.contactName = '',
    this.remarks = '',
    this.isActive = true,
    this.contractStartDate,
    this.contractEndDate,
  });

  bool get isExpired => contractEndDate != null && contractEndDate!.isBefore(DateTime.now());
}

// ─── Menu Item Model ─────────────────────────────────────────────────
class MenuItem {
  final String id;
  String name;
  bool isActive;

  MenuItem({required this.id, required this.name, this.isActive = true});
}

enum MenuCategory { hiTeaRegular, hiTeaPremium, lunchBuffetRegular, lunchBuffetPremium }

extension MenuCategoryExt on MenuCategory {
  String get label {
    switch (this) {
      case MenuCategory.hiTeaRegular: return 'Hi-Tea Regular';
      case MenuCategory.hiTeaPremium: return 'Hi-Tea Premium';
      case MenuCategory.lunchBuffetRegular: return 'Lunch Buffet Regular';
      case MenuCategory.lunchBuffetPremium: return 'Lunch Buffet Premium';
    }
  }

  String get group {
    switch (this) {
      case MenuCategory.hiTeaRegular:
      case MenuCategory.hiTeaPremium:
        return 'Hi-Tea';
      case MenuCategory.lunchBuffetRegular:
      case MenuCategory.lunchBuffetPremium:
        return 'Lunch Buffet';
    }
  }
}

// ─── Contractor Order Status (Kitchen-side acknowledgement) ──────────
enum ContractorOrderStatus { pending, received, prepared, served }

extension ContractorOrderStatusExt on ContractorOrderStatus {
  String get label {
    switch (this) {
      case ContractorOrderStatus.pending: return 'Pending';
      case ContractorOrderStatus.received: return 'Received';
      case ContractorOrderStatus.prepared: return 'Prepared';
      case ContractorOrderStatus.served: return 'Served';
    }
  }
}

// ─── HR Approver Model ───────────────────────────────────────────────
class HRApprover {
  final String id;
  final String employeeName;
  final String cpfNumber;
  final String designation;
  final String department;

  HRApprover({
    required this.id,
    required this.employeeName,
    required this.cpfNumber,
    required this.designation,
    required this.department,
  });
}

// ─── Catering Request Model ──────────────────────────────────────────
enum RequestStatus { submitted, approvedByApprover, approvedByHR, rejected, completed }

extension RequestStatusExt on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.submitted: return 'Submitted';
      case RequestStatus.approvedByApprover: return 'Approved by Approver';
      case RequestStatus.approvedByHR: return 'Approved by HR';
      case RequestStatus.rejected: return 'Rejected';
      case RequestStatus.completed: return 'Completed';
    }
  }

  bool get isApproved =>
      this == RequestStatus.approvedByApprover || this == RequestStatus.approvedByHR;
}

class CateringRequest {
  final String id;
  final String initiatorName;
  final String department;
  final DateTime initiatedOn;

  // Venue & Catering
  String venue;
  String cateringType;
  List<String> menuItems;

  // Meeting Details
  String natureOfMeeting;
  String presidingOfficer;
  String duration;

  // Pax & Provisions
  int hiTeaPax;
  int buffetPax;
  int mineralWaterBottles;
  List<String> packedItems;

  // Date & Time
  DateTime eventDate;
  String? hiTeaTime;
  String? buffetTime;

  // Approver
  String approverName;

  RequestStatus status;
  String? rejectionRemarks;

  // Contractor / Kitchen side
  String contractorId;
  String contractorInstructions;
  ContractorOrderStatus contractorStatus;
  String? initiatorAckRemarks;

  CateringRequest({
    required this.id,
    required this.initiatorName,
    required this.department,
    required this.initiatedOn,
    required this.venue,
    required this.cateringType,
    this.menuItems = const [],
    this.natureOfMeeting = '',
    this.presidingOfficer = '',
    this.duration = '1-2 hrs',
    this.hiTeaPax = 0,
    this.buffetPax = 0,
    this.mineralWaterBottles = 0,
    this.packedItems = const [],
    required this.eventDate,
    this.hiTeaTime,
    this.buffetTime,
    this.approverName = '',
    this.status = RequestStatus.submitted,
    this.rejectionRemarks,
    this.contractorId = '',
    this.contractorInstructions = '',
    this.contractorStatus = ContractorOrderStatus.pending,
    this.initiatorAckRemarks,
  });
}

// ─── Sample Data Store ───────────────────────────────────────────────
class AppDataStore {
  static final AppDataStore _instance = AppDataStore._internal();
  factory AppDataStore() => _instance;
  AppDataStore._internal();

  // Contractors
  List<Contractor> contractors = [
    Contractor(
      id: 'c1',
      name: 'Royal Caterers Pvt Ltd',
      email: 'royal@caterers.in',
      contactName: 'Ramesh Gupta',
      remarks: 'Primary canteen contractor',
      isActive: true,
      contractStartDate: DateTime(2026, 1, 1),
      contractEndDate: DateTime(2026, 12, 31),
    ),
    Contractor(
      id: 'c2',
      name: 'Spice Route Hospitality',
      email: 'orders@spiceroute.in',
      contactName: 'Sunita Sharma',
      remarks: 'Backup vendor',
      isActive: true,
      contractStartDate: DateTime(2026, 3, 1),
      contractEndDate: DateTime(2027, 2, 28),
    ),
  ];

  // Menu Items
  Map<MenuCategory, List<MenuItem>> menuItems = {
    MenuCategory.hiTeaRegular: [
      MenuItem(id: 'h1', name: 'Veg Samosa'),
      MenuItem(id: 'h2', name: 'Bread Pakora'),
      MenuItem(id: 'h3', name: 'Masala Tea'),
      MenuItem(id: 'h4', name: 'Filter Coffee'),
      MenuItem(id: 'h5', name: 'Assorted Biscuits'),
    ],
    MenuCategory.hiTeaPremium: [
      MenuItem(id: 'hp1', name: 'Mini Paneer Tikka'),
      MenuItem(id: 'hp2', name: 'Hara Bhara Kebab'),
      MenuItem(id: 'hp3', name: 'Cocktail Samosa'),
      MenuItem(id: 'hp4', name: 'Assorted Pastries'),
      MenuItem(id: 'hp5', name: 'Kashmiri Kahwa'),
      MenuItem(id: 'hp6', name: 'Fresh Fruit Platter'),
    ],
    MenuCategory.lunchBuffetRegular: [
      MenuItem(id: 'lr1', name: 'Dal Tadka'),
      MenuItem(id: 'lr2', name: 'Mix Veg Curry'),
      MenuItem(id: 'lr3', name: 'Jeera Rice'),
      MenuItem(id: 'lr4', name: 'Tandoori Roti'),
      MenuItem(id: 'lr5', name: 'Boondi Raita'),
      MenuItem(id: 'lr6', name: 'Gulab Jamun'),
    ],
    MenuCategory.lunchBuffetPremium: [
      MenuItem(id: 'lp1', name: 'Paneer Lababdar'),
      MenuItem(id: 'lp2', name: 'Dal Makhani'),
      MenuItem(id: 'lp3', name: 'Subz Biryani'),
      MenuItem(id: 'lp4', name: 'Butter Naan'),
      MenuItem(id: 'lp5', name: 'Murgh Tikka Masala'),
      MenuItem(id: 'lp6', name: 'Gajar Halwa'),
      MenuItem(id: 'lp7', name: 'Rasmalai'),
    ],
  };

  // HR Approvers
  List<HRApprover> hrApprovers = [
    HRApprover(
      id: 'a1',
      employeeName: 'Anil Verma',
      cpfNumber: 'CPF-10023',
      designation: 'General Manager',
      department: 'Operations',
    ),
    HRApprover(
      id: 'a2',
      employeeName: 'Suresh Iyer',
      cpfNumber: 'CPF-10045',
      designation: 'Chief General Manager',
      department: 'Marketing',
    ),
  ];

  // Requests
  List<CateringRequest> requests = [
    CateringRequest(
      id: '#2026001',
      initiatorName: 'Rajesh Kumar',
      department: 'Marketing',
      initiatedOn: DateTime(2026, 2, 10),
      venue: '4th Floor Conference Hall',
      cateringType: 'Premium Hi-Tea',
      menuItems: ['Mini Paneer Tikka', 'Hara Bhara Kebab', 'Cocktail Samosa', 'Assorted Pastries', 'Kashmiri Kahwa', 'Fresh Fruit Platter'],
      natureOfMeeting: 'Quarterly review meeting with regional heads',
      presidingOfficer: 'Director (Marketing)',
      duration: '2-4 hrs',
      hiTeaPax: 25,
      buffetPax: 0,
      mineralWaterBottles: 30,
      packedItems: ['Cookies', 'Mineral Water'],
      eventDate: DateTime(2026, 2, 15),
      hiTeaTime: '16:30',
      approverName: 'Suresh Iyer - CGM (Marketing)',
      status: RequestStatus.approvedByHR,
      contractorId: 'c1',
      contractorInstructions: 'Serve promptly at 4th Floor Conference Hall. Maintain hygiene standards; VIP guest present.',
      contractorStatus: ContractorOrderStatus.served,
    ),
    CateringRequest(
      id: '#2026003',
      initiatorName: 'Rajesh Kumar',
      department: 'Marketing',
      initiatedOn: DateTime(2026, 2, 12),
      venue: 'Cafeteria',
      cateringType: 'Regular Hi-Tea',
      menuItems: ['Veg Samosa', 'Bread Pakora', 'Masala Tea', 'Filter Coffee', 'Assorted Biscuits'],
      natureOfMeeting: 'Vendor meeting',
      presidingOfficer: '',
      duration: '1-2 hrs',
      hiTeaPax: 12,
      buffetPax: 15,
      mineralWaterBottles: 15,
      packedItems: [],
      eventDate: DateTime(2026, 2, 14),
      hiTeaTime: '15:30',
      approverName: 'Anil Verma - GM (Operations)',
      status: RequestStatus.approvedByHR,
      contractorId: 'c1',
      contractorInstructions: 'Regular service at Cafeteria counter.',
      contractorStatus: ContractorOrderStatus.prepared,
    ),
  ];

  int _requestCounter = 4;
  String get nextRequestId => '#2026${_requestCounter.toString().padLeft(3, '0')}';
  void incrementCounter() => _requestCounter++;
}
