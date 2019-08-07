// lang.timestamp module

# A duration in seconds, represented by a decimal.
public type Seconds decimal;

# A record type representing an instant in time relative to an epoch.
# It assumes that the epoch occurs at the start of a UTC day (i.e. midnight).
# This has the same information as a timestamp.
# All operations on timestamps cane be defined in terms of operations
# on the corresponding `Instant` record.
# `epochDays` is the number of days from the epoch to the start of the day
# on which the instant occurs.
# `utcTimeOfDaySeconds` is the duration in seconds from the start of the UTC day.
# `utcTimeOfDaySeconds` will be < 86,400 except on a day with a positive leap second,
# when it will be < 86,401.
# `localOffsetMinutes` is the number of minutes, possibly negative, by which local time is ahead
# of UTC time.
# Note that, unlike with the string representation of a timestamp, an
# `Instant` represents an instant in time relative to UTC, rather than
# relative to local time.
# Two timestamps are `==` if the `dayNumber` and `utcTimeOfDaySeconds` fields
# of the corresponding Instant are both `==`.
# Two timestamps are `===` if all fields of the corresponding Instant are `===`.
public type Instant record {|
    int epochDays;
    Seconds utcTimeOfDaySeconds;
    int localOffsetMinutes;
|};

# A timestamp for the Ballerina epoch.
public const timestamp EPOCH = 2000-01-01T00:00:00Z;

# The year of the Ballerina epoch.
public const int EPOCH_YEAR = 2000;

# Returns the Instant of `ts` relative to `EPOCH`.
# So `EPOCH.toInstant()` returns `{ epochDays: 0, utcTimeOfDaySeconds: 0d, localOffsetMinutes: 0 }`
public function toInstant(timestamp ts) returns Instant = external;

# Returns the timestamp corresponding to `instant`.
# Panics if `instant` does not correspond to any timestamp.
# A positive leap second is allowed for any day that is the last day of a month,
# on any year >= 1972.
# `ts === fromInstant(ts.toInstant())` will be true for any timestamp `ts`.
public function fromInstant(Instant instant) returns timestamp = external;

# Same as `ts.toInstant().epochDays`.
public function epochDays(timestamp ts) returns int = external;

# Same as `ts.toInstant().utcTimeOfDaySeconds`.
public function utcTimeOfDaySeconds(timestamp ts) returns Seconds = external;

# Same as `ts.toInstant().localOffsetMinutes`.
public function localOffsetMinutes(timestamp ts) returns int? = external;

# Converts a timestamp to a duration in seconds since the epoch.
# This ignores leap seconds.
# More precisely, this is equivalent to
# `(ts.epochDays() * 86400) - clampUtcTimeOfDaySeconds(ts.utcTimeOfDaySeconds())`.
public function toEpochSeconds(timestamp ts) returns Seconds = external;

# Reduces a time of day in seconds so that it excludes any partial leap seconds.
# More precisely, if `s` is >= 86400, returns the largest decimal number that is < 86400
# and has the same precision as `s`.
public function clampUtcTimeOfDaySeconds(Seconds s) returns Seconds = external;

# Converts a duration in seconds since the epoch to a timestamp.
# The local offset in the result will be 0. 
# Panics if out of range.
public function fromEpochSeconds(Seconds seconds) returns timestamp = external;

# Same as `ts1.toEpochSeconds() - ts2.toEpochSeconds()`.
public function subtract(timestamp ts1, timestamp ts2) returns Seconds = external;

# Convert from RFC3339 string
# Leap seconds allowed at the end of a UTC month only.
# Allow years that are not four digits
public function fromString(string) returns timestamp|error = external;

# Record type representing a calendar date in Gregorian calendar.
# A date is valid if the year is beteen 0 and 9999
# and represents a valid date in the proleptic Gregorien calendar.
# Year 0 means -1 BC.
public type Date record {|
    int year;
    int month;
    int day;
|};

// Using TimeOfDay because Time is so overloaded.
# Record type representing a time of day using 24-hour clock.
# `second` field can be >= 60 and < 61 during a positive leap-second
public type TimeOfDay record {|
    int hour;
    int minute;
    decimal second;
|};

# Offset of a time zone from UTC.
# This is conceptually a duration, but we use singular `hour` and `minute`
# since TimeOfDay is also duration from start of the day.
public type ZoneOffset {|
    # sign must be `+` if hour and and minute are both 0
    (+1|-1) sign;
    # in the range 0...23
    int hour;
    # in the range 0...59
    int minute;
|};

public const ZoneOffset ZONE_OFFSET_ZERO = { sign: +1, hours: 0, minutes: 0};

# Returns the date of `ts` in UTC
public function utcDate(timestamp ts) returns Date = external;

# Returns the date of the timestamp in the timestamp's local time zone
# This is the same as the date in the string representation of the timestamp.
public function localDate(timestamp ts) returns Date = external;

# Returns the time of `ts` in UTC
# This can be derived from the `utcTimeOfDaySeconds` of the corresponding Instant.
public function utcTimeOfDay(timestamp ts) returns TimeOfDay = external;

# Returns the time of day of `ts` in its local time zone.
# This is the same as the time in the string representation of the timestamp.
public function localTimeOfDay(timestamp ts) returns TimeOfDay = external;

# Returns the offset of local time of `ts` from UTC
public function localOffset(timestamp ts) returns ZoneOffset = external;

# Constructs a timestamp using a date, time of day and time-zone offset.
# The `date` and `time` are in a time zone that is ahead of UTC by `offset`
public function fromLocalDateTimeOffset(Date date, TimeOfDay time, ZoneOffset offset) returns timestamp = external;

# Returns a timestamp that refers to the same time instant, but with a different zone offset.
public function withLocalOffset(timestamp ts, ZoneOffset offset) returns timestamp = external;

// Leap seconds

# Does this timestamp occur during a positive leap second?
# Same as `ts.toInstant().utcTimeOfDaySeconds >= 86400d`
public function inLeapSecond(timestamp ts) returns boolean = external;


// Not sure if we need this: can implement easily with `fromString` and `inLeapSecond`.
# like fromString, but do not allow seconds field >= 60
public function fromNoLeapSecondsString(string) returns timestamp|error = external;

// Not sure if we need this: can implement efficiently with `inLeapSecond` and code below.
# Returns a timestamp that omits a partial leap second.
# Equivalent to
# ```
# Instant instant = ts.toInstant();
# instant.utcTimeOfDaySeconds = clampUtcTimeOfDaySeconds(instant.utcTimeOfDaySeconds);
# return fromInstant(instant);
# ```
public function withoutLeapSeconds(timestamp ts) returns timestamp = external;