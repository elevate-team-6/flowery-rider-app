enum DriverOrderState {
  completed('completed'),
  canceled('canceled');

  final String value;
  const DriverOrderState(this.value);

  static DriverOrderState? fromString(String status) {
    for (var state in DriverOrderState.values) {
      if (state.value == status.toLowerCase()) {
        return state;
      }
    }
    return null;
  }
}
