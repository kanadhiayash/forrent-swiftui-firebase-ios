# For Rent Functionality Stitching Map

| Product Requirement | Current File/Location | Current Status | Wire-Up Issue | Required Fix | Priority |
|---|---|---|---|---|---|
| User signup | `Views/Auth/SignUpView.swift`, `ViewModels/AuthViewModel.swift` | Upgraded | Validation was light | Uses `Validators.validateSignup`, creates Firebase user and `users/{uid}` | P0 |
| User login | `Views/Auth/LoginView.swift`, `AuthViewModel.swift` | Upgraded | No email/password guard | Validates input, fetches Firestore profile | P0 |
| User logout | `ProfileView.swift`, `AuthViewModel.swift` | Working | Guest exit reused logout | Keeps simple sign-out/local reset | P1 |
| Role selection | `SignUpView.swift` | Working | Tenant/landlord only | Preserve segmented picker | P1 |
| Role persistence | `FirestoreService.createUser`, `AuthViewModel.observeAuthState` | Upgraded | No launch restoration | Auth listener fetches `users/{uid}` | P0 |
| Landlord dashboard | `LandlordTabView.swift`, `MyPropertiesView.swift` | Upgraded | Listed all properties | Filters by `landlordId` | P0 |
| Tenant dashboard | `TenantTabView.swift`, `TenantHomeView.swift` | Upgraded | Showed all properties | Shows listed/unassigned properties | P0 |
| Guest experience | `GuestHomeView.swift`, `PropertyDetailView.swift` | Upgraded | Protected actions unclear | Browse/detail/share allowed; save/request prompt sign-in | P1 |
| Add property | `AddPropertyView.swift`, `PropertyViewModel.addProperty` | Upgraded | Ignored `isListed`; weak validation | Uses listing toggle, role guard, rent validation | P0 |
| Read/list properties | `PropertyViewModel.fetchProperties` | Working | No availability filter in UI | ViewModels expose available/landlord filters | P0 |
| Search properties | `TenantHomeView.swift`, `PropertyViewModel.filteredAvailableProperties` | Added | Missing | Title/details search | P1 |
| Filter properties | `TenantHomeView.swift` | Added | Missing | Max-rent filter | P1 |
| View property details | `PropertyDetailView.swift` | Upgraded | Force/user action gaps | Safe guest/tenant handling | P0 |
| Update property | `UpdatePropertyView.swift`, `PropertyViewModel.updateProperty` | Upgraded | Rent fallback to zero | Validates rent/title/details | P0 |
| Delete/de-list property | `MyPropertiesView.swift`, `PropertyViewModel.deleteProperty`, `setListing` | Upgraded | Delete did not delete | Firestore delete and de-list update | P0 |
| Shortlist property | `PropertyDetailView.swift`, `ShortlistViewModel` | Upgraded | Guest could silently save local IDs | Tenant guard and rollback on Firestore failure | P0 |
| Remove shortlist | `ShortlistView.swift`, `ShortlistViewModel` | Upgraded | Errors hidden | Swipe removal uses same rollback-aware toggle | P1 |
| Send rental request | `PropertyDetailView.swift`, `RequestViewModel.sendRequest` | Upgraded | `try?`, duplicates possible | Role guard, availability guard, duplicate guard, rollback | P0 |
| View sent requests | `RequestsView.swift` | Working | Shared view only | Filters tenant requests by `tenantId` | P1 |
| View received requests | `RequestsView.swift` | Working | Shared view only | Filters landlord requests by `landlordId` | P1 |
| Approve request | `RequestsView.swift`, `RequestViewModel.accept`, `FirestoreService.updateRequestStatus` | Upgraded | Did not update property availability | Batch updates request and property | P0 |
| Deny request | `RequestsView.swift`, `RequestViewModel.reject` | Upgraded | `try?` hid errors | Async error handling and rollback | P0 |
| Update property availability | `FirestoreService.updateRequestStatus`, `PropertyViewModel.setListing` | Upgraded | Incomplete | Accepted request marks assigned/unlisted; de-list toggle exists | P0 |
| Error alerts | `AlertViewModifier.swift`, ViewModels | Upgraded | Inconsistent | Added error messages across mutation view models | P1 |
| Loading indicators | `LoadingView.swift`, ViewModels | Upgraded | Partial | Used during auth/property/request/profile work | P1 |
| Empty states | `TenantHomeView.swift`, `MyPropertiesView.swift`, `RequestsView.swift`, `ShortlistView.swift` | Upgraded | Sparse | Added clearer empty copy where most important | P1 |
| Firestore document mapping | `Models/*.swift`, `FirestoreService.swift` | Working | IDs manually stored | Preserve stable explicit `id` fields | P1 |
| Navigation after actions | `AddPropertyView.swift`, `ContentView.swift` | Upgraded | Add did not close | Add dismisses on success; root routes by role | P1 |
| Access guards | ViewModels and `PropertyDetailView.swift` | Upgraded | Mostly UI-only before | ViewModels check role/ownership for mutations | P0 |
| Accessibility labels | `PropertyCardView.swift`, `LoginView.swift`, `TenantHomeView.swift` | Upgraded | Partial | Added key labels and combined card summary | P2 |
