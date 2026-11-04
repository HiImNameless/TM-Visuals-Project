namespace TMVisualsWebApp.Services
{
    /// <summary>
    /// Turns the database's time slots into the JSON the booking page's
    /// calendar already understands, and matches a chosen start and finish
    /// time back to the slots that cover it.
    /// </summary>
    public static class BookingCalendar
    {
        // South Africa is UTC+2 year-round, with no daylight saving.
        private static readonly TimeSpan SastOffset = TimeSpan.FromHours(2);

        public static DateTime NowSast => DateTime.UtcNow + SastOffset;

        public static string Format(TimeSpan time) => time.ToString(@"hh\:mm");

        /// <summary>The "days" object for one month, keyed by yyyy-MM-dd.</summary>
        public static Dictionary<string, DayAvailability> BuildMonth(
            int year,
            int month,
            IEnumerable<CalendarSlot> slots)
        {
            var now = NowSast;
            var byDay = slots
                .GroupBy(slot => slot.Date)
                .ToDictionary(group => group.Key, group => group.ToList());

            var result = new Dictionary<string, DayAvailability>();

            for (var day = 1; day <= DateTime.DaysInMonth(year, month); day++)
            {
                var date = new DateOnly(year, month, day);
                byDay.TryGetValue(date, out var daySlots);
                result[date.ToString("yyyy-MM-dd")] = BuildDay(date, daySlots, now);
            }

            return result;
        }

        private static DayAvailability BuildDay(
            DateOnly date,
            List<CalendarSlot>? slots,
            DateTime nowSast)
        {
            var today = DateOnly.FromDateTime(nowSast);

            // Past days, and days the photographer has not opened any slots on.
            if (date < today || slots is null || slots.Count == 0)
            {
                return new DayAvailability("blocked", new(), new());
            }

            // Today: a slot that has already started can't be booked.
            if (date == today)
            {
                slots = slots.Where(slot => slot.Start > nowSast.TimeOfDay).ToList();
            }

            var free = Merge(slots.Where(slot => slot.Available));
            var busy = Merge(slots.Where(slot => !slot.Available));

            var status = free.Count == 0 ? "full"
                       : busy.Count > 0 ? "partial"
                       : "available";

            return new DayAvailability(status, busy, free);
        }

        // Joins back-to-back slots into one window, e.g. 09-10 and 10-11 -> 09-11.
        private static List<TimeWindow> Merge(IEnumerable<CalendarSlot> slots)
        {
            var windows = new List<(TimeSpan From, TimeSpan To)>();

            foreach (var slot in slots.OrderBy(item => item.Start))
            {
                if (windows.Count > 0 && slot.Start <= windows[^1].To)
                {
                    var last = windows[^1];
                    windows[^1] = (last.From, slot.End > last.To ? slot.End : last.To);
                }
                else
                {
                    windows.Add((slot.Start, slot.End));
                }
            }

            return windows
                .Select(window => new TimeWindow(Format(window.From), Format(window.To)))
                .ToList();
        }

        /// <summary>
        /// The slots that exactly fill start to finish with no gaps, or null when
        /// the times don't line up with the slot boundaries.
        /// </summary>
        public static List<CalendarSlot>? Cover(
            IEnumerable<CalendarSlot> daySlots,
            TimeSpan start,
            TimeSpan finish)
        {
            var inside = daySlots
                .Where(slot => slot.Start >= start && slot.End <= finish)
                .OrderBy(slot => slot.Start)
                .ToList();

            if (inside.Count == 0 ||
                inside[0].Start != start ||
                inside[^1].End != finish)
            {
                return null;
            }

            for (var index = 1; index < inside.Count; index++)
            {
                if (inside[index].Start != inside[index - 1].End)
                {
                    return null;
                }
            }

            return inside;
        }
    }
}
