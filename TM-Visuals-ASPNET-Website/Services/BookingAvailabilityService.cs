using System.Globalization;
using System.Text.Json;

namespace TMVisualsWebApp.Services;

public record TimeWindow(string From, string To, List<string>? Boundaries = null);
public record DayAvailability(string Status, List<TimeWindow> Busy, List<TimeWindow> Free);

public sealed class BookingAvailabilityService(SupabaseApiClient api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    public async Task<Dictionary<string, DayAvailability>> GetMonthAsync(
        int year, int month, CancellationToken cancellationToken = default)
    {
        var first = new DateTime(year, month, 1);
        var last = first.AddMonths(1).AddDays(-1);
        var rows = await api.RpcAsync("get_calendar_availability", new {
            p_start_date = first.ToString("yyyy-MM-dd",CultureInfo.InvariantCulture),
            p_end_date = last.ToString("yyyy-MM-dd",CultureInfo.InvariantCulture),
        }, cancellationToken: cancellationToken);
        var days = new Dictionary<string, DayAvailability>();
        foreach (var row in rows.EnumerateArray())
        {
            var key = row.GetProperty("slot_date").GetString()!;
            var status = row.GetProperty("status").GetString()!;
            if (status is not ("available" or "partial" or "full" or "blocked"))
                throw new JsonException("Unexpected calendar state.");
            days.Add(key,new DayAvailability(status,
                row.GetProperty("busy").Deserialize<List<TimeWindow>>(Json)!,
                row.GetProperty("free").Deserialize<List<TimeWindow>>(Json)!));
        }
        if (days.Count != last.Day || Enumerable.Range(1,last.Day).Any(day =>
            !days.ContainsKey(new DateTime(year,month,day).ToString("yyyy-MM-dd",CultureInfo.InvariantCulture))))
            throw new JsonException("The calendar response did not include the requested month.");
        return days;
    }
}
