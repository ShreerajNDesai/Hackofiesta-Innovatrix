# Traffic signal threshold
THRESHOLD_HIGH = 3  # Reduce to 3 for easier GREEN signal
THRESHOLD_LOW = 1   # Vehicles must reduce to this to turn RED

# Set traffic signals based on vehicle count
for lane_idx, count in lane_counts.items():
    prev_signal = signal_status.get(lane_idx, "RED")
    
    if prev_signal == "RED" and count >= THRESHOLD_HIGH:
        signal_status[lane_idx] = "GREEN"  # Turn green if traffic is high
    elif prev_signal == "GREEN" and count <= THRESHOLD_LOW:
        signal_status[lane_idx] = "RED"  # Turn red if traffic reduces significantly

    # Debugging: Print counts to check logic
    print(f"🚗 Lane {lane_idx + 1}: {count} vehicles → Signal: {signal_status[lane_idx]}")
