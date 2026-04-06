# API Implementation Pattern - Repository to ViewModel

This document describes the standardized pattern for implementing API data fetching from Repository layer to ViewModel layer in the Browny application.

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [API Client Layer](#api-client-layer)
3. [Repository Layer](#repository-layer)
4. [ViewModel Layer](#viewmodel-layer)
5. [Data Flow](#data-flow)
6. [Error Handling](#error-handling)
7. [Implementation Steps](#implementation-steps)
8. [Examples](#examples)
9. [Best Practices](#best-practices)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                         UI Layer                         │
│                  (ValueListenableBuilder)                │
└──────────────────────┬──────────────────────────────────┘
                       │ listens to
                       ▼
┌─────────────────────────────────────────────────────────┐
│                    ViewModel Layer                       │
│  • ValueNotifier<UiResult<T>>                           │
│  • Business Logic                                        │
│  • Data Transformation                                   │
└──────────────────────┬──────────────────────────────────┘
                       │ calls
                       ▼
┌─────────────────────────────────────────────────────────┐
│                   Repository Layer                       │
│  • DataSourceMixin (interface)                          │
│  • Repo Class (implementation)                          │
│  • RepoResult<T> wrapper                                │
└──────────────────────┬──────────────────────────────────┘
                       │ uses
                       ▼
┌─────────────────────────────────────────────────────────┐
│                   API Client Layer                       │
│  • Retrofit + Dio                                        │
│  • HttpResponse<T>                                       │
└─────────────────────────────────────────────────────────┘
```

---

## API Client Layer

### 1. Define API Endpoint in `app_client.dart`

```dart
/// DONG 2026-02-20
///
/// API fetch ข้อมูล Contact (social media links)
@GET('/contact')
Future<HttpResponse<ContactResponse>> fetchContact();
```

**Key Points:**
- Use Retrofit annotations (`@GET`, `@POST`, `@PUT`, etc.)
- Document with Thai comments explaining the API purpose
- Include date stamp (`DONG YYYY-MM-DD`)
- Return `HttpResponse<T>` wrapper

### 2. Create Response Model

```dart
@JsonSerializable()
class ContactResponse {
  @JsonKey(name: 'facebook_link')
  final String? facebookLink;

  @JsonKey(name: 'line_link')
  final String? lineLink;

  ContactResponse({
    this.facebookLink,
    this.lineLink,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) =>
      _$ContactResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ContactResponseToJson(this);
}
```

### 3. Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Repository Layer

### 1. Define Mixin Interface

```dart
mixin ContactDataSourceMixin {
  /// API fetch ข้อมูล Contact (social media links)
  Future<RepoResult<ContactResponse>> fetchContact();
}
```

**Purpose:**
- Acts as an interface/contract
- Defines what methods the repository must implement
- Enables dependency injection and testing

### 2. Implement Repository Class

```dart
class ContactRepo extends AppRepository with ContactDataSourceMixin {
  @override
  Future<RepoResult<ContactResponse>> fetchContact() async {
    try {
      // 1. Call API through requireRemote
      final response = await requireRemote.fetchContact();
      
      // 2. Check response status
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      
      // 3. Return success with data
      return RepoResult.success(data: response.data);
      
    } on Exception catch (e) {
      // 4. Handle errors
      return RepoResult.error(error: e);
    }
  }
}
```

**Key Components:**
- **`extends AppRepository`**: Provides access to `requireRemote` (API client)
- **`with DataSourceMixin`**: Mixes in the interface
- **`RepoResult<T>`**: Wrapper for repository responses (success/empty/error)
- **`requireRemote`**: Access to AppClient singleton
- **`response.isSuccessful`**: Extension method to check HTTP status (200-299)

### 3. RepoResult States

```dart
// Success with data
RepoResult.success(data: responseData)

// Empty result (no data, but not an error)
RepoResult.empty()

// Error state
RepoResult.error(error: exception)

// Depends on another result
RepoResult.dependOn(someResponse)
```

---

## ViewModel Layer

### 1. ViewModel Structure

```dart
class ContactViewmodel extends AppViewModel {
  ContactViewmodel({
    required super.context,
    required this.repo,
  });

  final ContactDataSourceMixin repo;

  // ========== Dispose ==========
  @override
  void dispose() {
    _contactNotifier.dispose();
    super.dispose();
  }

  // ========== ValueNotifier ==========
  final ValueNotifier<UiResult<ContactResponse>> _contactNotifier =
      ValueNotifier(UiResult.loading());
  
  ValueListenable<UiResult<ContactResponse>> get contactNotifier =>
      _contactNotifier;

  // ========== Logic ==========
  /// API fetch ข้อมูล Contact (social media links)
  Future<void> fetchContact() async {
    // 1. Set loading state
    _contactNotifier.value = UiResult.loading();

    // 2. Call repository
    final result = await repo.fetchContact();

    // 3. Handle error case
    if (result.hasError) {
      _contactNotifier.value = UiResult.error(error: result.error);
      return;
    }

    // 4. Handle empty case
    if (result.isEmpty) {
      _contactNotifier.value = UiResult.empty();
      return;
    }

    // 5. Handle success case
    _contactNotifier.value = UiResult.success(data: result.data);
  }
}
```

### 2. UiResult States

```dart
// Loading state (show spinner)
UiResult.loading()

// Success with data
UiResult.success(data: responseData)

// Empty result (show empty state)
UiResult.empty()

// Error state (show error message)
UiResult.error(error: exception)
```

### 3. UiResult Helper Methods

```dart
result.isLoading   // true if loading
result.hasError    // true if error occurred
result.isEmpty     // true if empty result
result.isSuccess   // true if successful
result.data        // access data (nullable)
result.error       // access error (nullable)
```

---

## Data Flow

### Complete Flow Diagram

```
┌─────────┐
│   UI    │  Calls viewmodel.fetchData()
└────┬────┘
     │
     ▼
┌─────────────────────────────────────────┐
│            ViewModel                     │
│  1. Set UiResult.loading()              │
│  2. Call repo.fetchData()               │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│           Repository                     │
│  1. Call requireRemote.fetchData()      │
│  2. Check response.isSuccessful         │
│  3. Return RepoResult<T>                │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│          API Client (Retrofit)          │
│  1. Execute HTTP request                │
│  2. Parse JSON to Response model        │
│  3. Return HttpResponse<T>              │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│         Backend API                      │
│  Return JSON response                    │
└─────────────────────────────────────────┘
```

### State Changes

```
UI triggers fetch
       │
       ▼
UiResult.loading() → UI shows loading spinner
       │
       ▼
API call in progress
       │
       ├─→ Success → UiResult.success(data) → UI shows data
       │
       ├─→ Empty   → UiResult.empty()       → UI shows empty state
       │
       └─→ Error   → UiResult.error(error)  → UI shows error message
```

---

## Error Handling

### Repository Layer Error Handling

```dart
Future<RepoResult<T>> fetchData() async {
  try {
    final response = await requireRemote.fetchData();
    
    // HTTP error (4xx, 5xx)
    if (!response.isSuccessful) {
      return RepoResult.empty(
        error: Exception(
          'HTTP ${response.response.statusCode}: ${response.response.statusMessage}',
        ),
      );
    }
    
    // No data returned
    if (response.data == null) {
      return RepoResult.empty();
    }
    
    return RepoResult.success(data: response.data);
    
  } on DioException catch (dio) {
    // Network errors, timeouts, etc.
    return RepoResult.error(error: dio);
    
  } on Exception catch (e) {
    // Other exceptions
    return RepoResult.error(error: e);
  }
}
```

### ViewModel Layer Error Handling

```dart
Future<void> fetchData() async {
  _notifier.value = UiResult.loading();

  final result = await repo.fetchData();

  // Check error first
  if (result.hasError) {
    _notifier.value = UiResult.error(error: result.error);
    return;
  }

  // Then check empty
  if (result.isEmpty) {
    _notifier.value = UiResult.empty();
    return;
  }

  // Finally handle success
  _notifier.value = UiResult.success(data: result.data);
}
```

### UI Layer Error Display

```dart
ValueListenableBuilder<UiResult<T>>(
  valueListenable: viewmodel.dataNotifier,
  builder: (context, result, _) {
    // Loading state
    if (result.isLoading) {
      return const CircularProgressIndicator();
    }

    // Error state
    if (result.hasError) {
      return ErrorWidget(
        message: result.error.toString(),
        onRetry: () => viewmodel.fetchData(),
      );
    }

    // Empty state
    if (result.isEmpty) {
      return const EmptyStateWidget(
        message: 'No data available',
      );
    }

    // Success state
    final data = result.data!;
    return YourDataWidget(data: data);
  },
)
```

---

## Implementation Steps

### Step-by-Step Checklist

#### 1. API Client Setup
- [ ] Define endpoint in `app_client.dart`
- [ ] Create response model with `@JsonSerializable()`
- [ ] Add model export to `api_model_index.dart`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verify no compilation errors

#### 2. Repository Implementation
- [ ] Create mixin interface with method signature
- [ ] Create repository class extending `AppRepository`
- [ ] Mix in the data source interface
- [ ] Implement fetch method with error handling
- [ ] Return appropriate `RepoResult` states

#### 3. ViewModel Implementation
- [ ] Create viewmodel class extending `AppViewModel`
- [ ] Add repository as constructor parameter
- [ ] Create private `ValueNotifier<UiResult<T>>`
- [ ] Create public `ValueListenable<UiResult<T>>` getter
- [ ] Implement fetch method with state management
- [ ] Override `dispose()` to dispose notifiers

#### 4. UI Integration
- [ ] Inject repository into viewmodel
- [ ] Use `ValueListenableBuilder` to observe state
- [ ] Handle all UiResult states (loading/error/empty/success)
- [ ] Call fetch method on initialization or user action

---

## Examples

### Example 1: Simple API Fetch (No Data Transformation)

**API Endpoint:**
```dart
@GET('/contact')
Future<HttpResponse<ContactResponse>> fetchContact();
```

**Repository:**
```dart
mixin ContactDataSourceMixin {
  Future<RepoResult<ContactResponse>> fetchContact();
}

class ContactRepo extends AppRepository with ContactDataSourceMixin {
  @override
  Future<RepoResult<ContactResponse>> fetchContact() async {
    try {
      final response = await requireRemote.fetchContact();
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
```

**ViewModel:**
```dart
class ContactViewmodel extends AppViewModel {
  ContactViewmodel({
    required super.context,
    required this.repo,
  });

  final ContactDataSourceMixin repo;

  final ValueNotifier<UiResult<ContactResponse>> _contactNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<ContactResponse>> get contactNotifier =>
      _contactNotifier;

  @override
  void dispose() {
    _contactNotifier.dispose();
    super.dispose();
  }

  Future<void> fetchContact() async {
    _contactNotifier.value = UiResult.loading();
    final result = await repo.fetchContact();

    if (result.hasError) {
      _contactNotifier.value = UiResult.error(error: result.error);
      return;
    }

    if (result.isEmpty) {
      _contactNotifier.value = UiResult.empty();
      return;
    }

    _contactNotifier.value = UiResult.success(data: result.data);
  }
}
```

**UI Usage:**
```dart
ValueListenableBuilder(
  valueListenable: viewmodel.contactNotifier,
  builder: (context, result, _) {
    if (result.isLoading) return CircularProgressIndicator();
    if (result.hasError) return ErrorWidget();
    if (result.isEmpty) return EmptyStateWidget();
    
    final contact = result.data!;
    return Column(
      children: [
        Text(contact.facebookLink ?? ''),
        Text(contact.lineLink ?? ''),
      ],
    );
  },
)
```

---

### Example 2: Complex Data Transformation

**API Endpoint:**
```dart
@GET('/coin/history')
Future<HttpResponse<CoinHistoryResponse>> fetchCoinHistory(
  @Body() Map<String, dynamic> body,
);
```

**Repository:**
```dart
mixin CoinDataSourceMixin {
  Future<RepoResult<CoinHistoryResponse>> fetchCoinHistory(String customerId);
}

class CoinRepo extends AppRepository with CoinDataSourceMixin {
  @override
  Future<RepoResult<CoinHistoryResponse>> fetchCoinHistory(
    String customerId,
  ) async {
    try {
      final response = await requireRemote.fetchCoinHistory({
        'customer_id': customerId,
      });
      
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
```

**ViewModel with Data Transformation:**
```dart
class CoinViewmodel extends AppViewModel {
  CoinViewmodel({
    required super.context,
    required this.repo,
  });

  final CoinDataSourceMixin repo;

  // Original response
  final ValueNotifier<UiResult<CoinHistoryResponse>> _coinHistoryNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<CoinHistoryResponse>> get coinHistoryNotifier =>
      _coinHistoryNotifier;

  // Transformed data (grouped by month)
  final ValueNotifier<UiResult<List<CoinHistoryGroup>>>
      _coinHistoryGroupsNotifier = ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<CoinHistoryGroup>>>
      get coinHistoryGroupsNotifier => _coinHistoryGroupsNotifier;

  @override
  void dispose() {
    _coinHistoryNotifier.dispose();
    _coinHistoryGroupsNotifier.dispose();
    super.dispose();
  }

  Future<void> fetchCoinHistory() async {
    // 1. Set loading state
    _coinHistoryNotifier.value = UiResult.loading();
    _coinHistoryGroupsNotifier.value = UiResult.loading();

    // 2. Fetch data
    final result = await repo.fetchCoinHistory(
      currentCustomerProvider.current.id,
    );

    // 3. Handle errors
    if (result.hasError) {
      _coinHistoryNotifier.value = UiResult.error(error: result.error);
      _coinHistoryGroupsNotifier.value = UiResult.error(error: result.error);
      return;
    }

    if (result.isEmpty) {
      _coinHistoryNotifier.value = UiResult.empty();
      _coinHistoryGroupsNotifier.value = UiResult.empty();
      return;
    }

    // 4. Set original response
    _coinHistoryNotifier.value = UiResult.success(data: result.data);

    // 5. Transform data (group by month)
    if (context.mounted) {
      final locale = Localizations.localeOf(context).languageCode;
      final historyItems = result.data.data?.history ?? [];
      
      // Group by month
      final groups = historyItems.groupByMonth(locale);
      
      _coinHistoryGroupsNotifier.value = UiResult.success(data: groups);
    }
  }
}
```

---

### Example 3: Multiple Dependent API Calls

**Repository:**
```dart
mixin ProfileDataSourceMixin {
  Future<RepoResult<CustomerProfileData>> fetchProfileInfo(String id);
  Future<RepoResult<CoinClaimResponse>> fetchCoinClaimData(String id);
}
```

**ViewModel:**
```dart
Future<void> fetchCoinClaimData() async {
  String id = currentCustomerProvider.current.id!;
  
  // 1. First API call - get profile
  final profileResult = await repo.fetchProfileInfo(id);

  if (profileResult.isError || profileResult.isEmpty) {
    _coinClaimDataNotifier.value = UiResult.error(
      error: Exception(profileResult.error.toString()),
    );
    return;
  }

  // 2. Second API call - get coin claim data
  final coinResult = await repo.fetchCoinClaimData(id);

  if (coinResult.isEmpty) {
    _coinClaimDataNotifier.value = UiResult.empty();
    return;
  }
  
  if (coinResult.hasError) {
    _coinClaimDataNotifier.value = UiResult.error(error: coinResult.error);
    return;
  }

  // 3. Transform and combine data
  if (context.mounted) {
    final data = CoinDataModel.fromCoinClaimData(
      Localizations.localeOf(context).languageCode,
      coinResult.data.data!,
    );

    _coinClaimDataNotifier.value = UiResult.success(data: data);
  }
}
```

---

## Best Practices

### 1. Repository Layer

✅ **DO:**
- Always extend `AppRepository` to access `requireRemote`
- Use mixin for interface definition
- Return `RepoResult<T>` wrapper
- Handle all exceptions with try-catch
- Check `response.isSuccessful` before returning success
- Use appropriate error types (DioException, Exception)

❌ **DON'T:**
- Don't put business logic in repository
- Don't transform data in repository (do it in ViewModel)
- Don't return null from repository methods
- Don't ignore error cases

### 2. ViewModel Layer

✅ **DO:**
- Always extend `AppViewModel`
- Use private `ValueNotifier` with public `ValueListenable` getter
- Initialize with `UiResult.loading()` if fetch is automatic
- Set loading state before API call
- Handle all RepoResult states (error/empty/success)
- Check `context.mounted` before using context
- Override `dispose()` to dispose all notifiers
- Document methods with Thai comments

❌ **DON'T:**
- Don't expose mutable `ValueNotifier` directly
- Don't forget to dispose notifiers
- Don't use context after async gap without checking `mounted`
- Don't perform heavy computation in ViewModel

### 3. Naming Conventions

```dart
// Mixin
ContactDataSourceMixin

// Repository
ContactRepo

// ViewModel
ContactViewmodel

// Notifier (private)
_contactNotifier

// Getter (public)
contactNotifier

// Fetch method
fetchContact()
```

### 4. File Organization

```
lib/
├── core/
│   ├── data/
│   │   ├── remote/
│   │   │   ├── app_client.dart          # API endpoints
│   │   │   └── models/
│   │   │       └── response/
│   │   │           └── contact_response.dart
│   │   └── repo/
│   │       └── app_repository.dart      # Base repository
│   └── utils/
│       ├── repo_result.dart             # RepoResult wrapper
│       └── ui_result.dart               # UiResult wrapper
└── feature/
    └── contacts/
        ├── repository/
        │   └── contact_repo.dart        # Repository implementation
        └── viewmodel/
            └── contact_viewmodel.dart   # ViewModel implementation
```

### 5. Error Messages

```dart
// Repository - Generic errors
RepoResult.empty(
  error: Exception('HTTP 404: Not Found'),
);

// ViewModel - User-facing errors
if (result.hasError) {
  // Log for debugging
  debugPrint('Fetch error: ${result.error}');
  
  // Set error state
  _notifier.value = UiResult.error(error: result.error);
}
```

### 6. Testing Considerations

```dart
// Repository interface (mixin) allows easy mocking
class MockContactRepo with ContactDataSourceMixin {
  @override
  Future<RepoResult<ContactResponse>> fetchContact() async {
    // Return mock data
    return RepoResult.success(
      data: ContactResponse(facebookLink: 'test'),
    );
  }
}

// Inject mock in tests
final viewmodel = ContactViewmodel(
  context: context,
  repo: MockContactRepo(),
);
```

---

## Common Patterns

### Pattern 1: Pagination

```dart
class ListViewmodel extends AppViewModel {
  final ValueNotifier<UiResult<List<Item>>> _itemsNotifier =
      ValueNotifier(UiResult.loading());
  
  int _currentPage = 1;
  bool _hasMoreData = true;

  Future<void> fetchItems({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMoreData) return;
      _currentPage++;
    } else {
      _currentPage = 1;
      _itemsNotifier.value = UiResult.loading();
    }

    final result = await repo.fetchItems(page: _currentPage);

    if (result.hasError) {
      _itemsNotifier.value = UiResult.error(error: result.error);
      return;
    }

    if (result.isEmpty) {
      _hasMoreData = false;
      if (_currentPage == 1) {
        _itemsNotifier.value = UiResult.empty();
      }
      return;
    }

    final newItems = result.data.items;
    if (loadMore && _itemsNotifier.value.isSuccess) {
      final existingItems = _itemsNotifier.value.data!;
      _itemsNotifier.value = UiResult.success(
        data: [...existingItems, ...newItems],
      );
    } else {
      _itemsNotifier.value = UiResult.success(data: newItems);
    }
  }
}
```

### Pattern 2: Refresh

```dart
Future<void> refresh() async {
  // Don't show loading spinner on refresh
  final result = await repo.fetchData();

  if (result.hasError) {
    // Show snackbar instead of error state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to refresh')),
    );
    return;
  }

  if (result.isEmpty) {
    _notifier.value = UiResult.empty();
    return;
  }

  _notifier.value = UiResult.success(data: result.data);
}
```

### Pattern 3: Cache with API

```dart
Future<void> fetchData({bool forceRefresh = false}) async {
  // Try cache first
  if (!forceRefresh) {
    final cached = await localRepo.getCachedData();
    if (cached != null) {
      _notifier.value = UiResult.success(data: cached);
    }
  }

  // Fetch from API
  final result = await repo.fetchData();

  if (result.isSuccess) {
    // Update cache
    await localRepo.cacheData(result.data);
    _notifier.value = UiResult.success(data: result.data);
  }
}
```

---

## Troubleshooting

### Common Issues

**Issue 1: `requireRemote` not found**
```dart
// ❌ Wrong
class MyRepo with MyDataSourceMixin {
  // Missing extends AppRepository
}

// ✅ Correct
class MyRepo extends AppRepository with MyDataSourceMixin {
}
```

**Issue 2: `isSuccessful` not defined**
```dart
// ❌ Missing import
import 'package:browny_applications_new/core/utils/repo_result.dart';

// ✅ Correct - Add extension import
import 'package:browny_applications_new/core/utils/app_extensions.dart';
```

**Issue 3: Context used after async**
```dart
// ❌ Wrong
final result = await repo.fetchData();
final locale = Localizations.localeOf(context).languageCode; // Unsafe!

// ✅ Correct
final result = await repo.fetchData();
if (context.mounted) {
  final locale = Localizations.localeOf(context).languageCode;
}
```

**Issue 4: Notifier not disposed**
```dart
// ❌ Wrong
class MyViewmodel extends AppViewModel {
  final _notifier = ValueNotifier(UiResult.loading());
  // Missing dispose override
}

// ✅ Correct
class MyViewmodel extends AppViewModel {
  final _notifier = ValueNotifier(UiResult.loading());
  
  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }
}
```

---

## Summary Checklist

When implementing a new API fetch feature:

1. ✅ Create response model with `@JsonSerializable()`
2. ✅ Add API endpoint in `app_client.dart`
3. ✅ Run build_runner to generate serialization code
4. ✅ Create repository mixin interface
5. ✅ Implement repository class extending `AppRepository`
6. ✅ Add error handling in repository
7. ✅ Create ViewModel extending `AppViewModel`
8. ✅ Add repository dependency injection
9. ✅ Create ValueNotifier + ValueListenable
10. ✅ Implement fetch method with state management
11. ✅ Override dispose() to clean up notifiers
12. ✅ Use ValueListenableBuilder in UI
13. ✅ Handle all UiResult states in UI
14. ✅ Test error cases, empty cases, and success cases

---

## References

- `lib/core/data/repo/app_repository.dart` - Base repository
- `lib/core/utils/repo_result.dart` - Repository result wrapper
- `lib/core/utils/ui_result.dart` - UI result wrapper
- `lib/core/data/remote/app_client.dart` - API client
- `lib/feature/contacts/` - Simple example
- `lib/feature/coin/` - Complex example with transformation

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-20  
**Author:** Browny Development Team
