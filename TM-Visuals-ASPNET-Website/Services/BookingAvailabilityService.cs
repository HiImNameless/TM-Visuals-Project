using TMVisualsWebApp.Models;

namespace TMVisualsWebApp.Services
{
    public record TimeWindow(string From, string To);

    /// <param name="Status">"available", "partial", "full" or "blocked"</param>
    public record DayAvailability(string Status, List<TimeWindow> Busy, List<TimeWindow> Free);

    public class BookingAvailabilityService
    {
        // Adjust these to match how you actually work.
        private static readonly TimeSpan Opening = TimeSpan.FromHours(6);
        private static readonly TimeSpan Closing = TimeSpan.FromHours(22);
        private static readonly TimeSpan Buffer = TimeSpan.FromMinutes(60);        // travel time either side
        private static readonly TimeSpan MinimumSession = TimeSpan.FromHours(1);

        // South Africa is UTC+2 year-round (same approach as BookingController).
        private static readonly TimeSpan SastOffset = TimeSpan.FromHours(2);
        private static DateTime NowSast => DateTime.UtcNow + SastOffset;

        private readonly BookingStore _store;
        private readonly object _reserveLock = new();

        public BookingAvailabilityService(BookingStore store)
        {
            _store = store;
        }

        public Dictionary<string, DayAvailability> GetMonth(int year, int month)
        {
            var result = new Dictionary<string, DayAvailability>();

            for (var day = 1; day <= DateTime.DaysInMonth(year, month); day++)
            {
                var date = new DateTime(year, month, day);
                result[date.ToString("yyyy-MM-dd")] = GetDay(date);
            }

            return result;
        }

        public DayAvailability GetDay(DateTime date)
        {
            if (date.Date < NowSast.Date || _store.IsBlocked(date))
            {
                return new DayAvailability("blocked", new(), new());
            }

            var (busy, free) = Compute(date);

            var status = free.Count == 0 ? "full"
                       : busy.Count > 0 ? "partial"
                       : "available";

            return new DayAvailability(
                status,
                busy.Select(w => new TimeWindow(Fmt(w.From), Fmt(w.To))).ToList(),
                free.Select(w => new TimeWindow(Fmt(w.From), Fmt(w.To))).ToList());
        }

        public bool IsSlotFree(DateTime date, TimeSpan start, TimeSpan finish)
        {
            if (finish <= start ||
                date.Date < NowSast.Date ||
                _store.IsBlocked(date))
            {
                return false;
            }

            return Compute(date).Free.Any(w => start >= w.From && finish <= w.To);
        }

        /// <summary>
        /// Checks the slot and saves the booking as one step, so two people
        /// submitting at the same moment cannot both get the same time.
        /// </summary>
        public bool TryReserve(Booking booking)
        {
            if (booking.Date is null ||
                booking.StartTime is null ||
                booking.FinishTime is null)
            {
                return false;
            }

            lock (_reserveLock)
            {
                if (!IsSlotFree(
                        booking.Date.Value,
                        booking.StartTime.Value,
                        booking.FinishTime.Value))
                {
                    return false;
                }

                _store.Add(booking);
                return true;
            }
        }

        private (List<(TimeSpan From, TimeSpan To)> Busy,
                 List<(TimeSpan From, TimeSpan To)> Free) Compute(DateTime date)
        {
            // Each booking blocks its own time plus the buffer on either side.
            var busy = _store.BookingsOn(date)
                .Select(b => (From: b.StartTime!.Value - Buffer,
                              To: b.FinishTime!.Value + Buffer))
                .OrderBy(x => x.From)
                .ToList();

            // Today: nothing earlier than the current time can be booked.
            var cursor = date.Date == NowSast.Date
                ? Max(Opening, NowSast.TimeOfDay)
                : Opening;

            var free = new List<(TimeSpan From, TimeSpan To)>();

            foreach (var (from, to) in busy)
            {
                if (from - cursor >= MinimumSession)
                {
                    free.Add((cursor, from));
                }

                if (to > cursor)
                {
                    cursor = to;
                }
            }

            if (Closing - cursor >= MinimumSession)
            {
                free.Add((cursor, Closing));
            }

            var shownBusy = busy
                .Select(w => (From: Clamp(w.From), To: Clamp(w.To)))
                .ToList();

            return (shownBusy, free);
        }

        private static TimeSpan Max(TimeSpan a, TimeSpan b) => a >= b ? a : b;

        private static TimeSpan Clamp(TimeSpan t) =>
            t < Opening ? Opening : t > Closing ? Closing : t;

        private static string Fmt(TimeSpan t) => t.ToString(@"hh\:mm");
    }
}