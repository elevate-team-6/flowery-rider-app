enum OrderStatus {
  completed('completed'),
  canceled('canceled');

  final String value;
  const OrderStatus(this.value);
}
