abstract class BaseRepository {
  /// Method to handle API calls and return either success or failure
  Future<T?> executeApiCall<T>(Future<T> apiCall()) async {
    try {
      final result = await apiCall();
      return result;
    } catch (error) {
      // Handle error appropriately
      throw error;
    }
  }
}
